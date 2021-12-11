module Homebrew
  module_function

  XDG_CONFIG_HOME = ENV["XDG_CONFIG_HOME"]
  $config, = Dir["{,#{XDG_CONFIG_HOME}/,#{Dir.home}/.}dock{et,}.{y{a,}ml,json}"]
  $config ||= "#{Dir.home}/.docket.yaml"

  def docket_args
    Homebrew::CLI::Parser.new do
      description <<~EOS
        Simple wrapper around <dockutil> to easily configure your Dock with a
        <dock>[<et>]<.y>[<a>]<ml> or <.json> file. This will reside in the
        current directory, else globally in #{$config.sub Dir.home, "~"}.
      EOS
      switch "-d", "--dump", description: <<~EOS
        Print your current Dock configuration in YAML (or <--json>) format.
        Optionally specify a config file to save output.
      EOS

      switch "-j", "--json", description: "Force JSON over YAML format."

      named_args :config, max: 1
    end
  end

  def docket
    args = docket_args.parse

    verbose = "-v" if args.verbose? || args.debug?

    dockutil = "#{HOMEBREW_PREFIX}/bin/dockutil"

    $config, = args.named if args.named.any?
    json = args.json?

    if args.dump?
      plist = Plist.parse_xml `defaults export com.apple.dock.plist -`

      config = { apps: [], others: [] }

      plist["persistent-apps"].each do |app|
        spacer = app["tile-type"] == "spacer-tile"
        app = app["tile-data"]["file-label"]
        config[:apps].push spacer ? "spacer" : app
      end

      plist["persistent-others"].each do |other|
        tile_data = other["tile-data"]

        config[:others].push \
          case other["tile-type"]
          when "spacer-tile" then "spacer"
          when "url-tile"
            url = tile_data["url"]["_CFURLString"]
            label = tile_data["label"]
            label == url ? url : { url: url, label: label }
          else
            path = tile_data.dig "file-data", "_CFURLString"
            folder = path.gsub(%r{^file://|/$}, "").sub Dir.home, "~"

            showas = %w[auto fan grid list] # 0–3
            displayas = %w[stack folder] # 0–1
            arrangement = %w[name dateadded datemodified datecreated kind] # 1–5

            view = showas[tile_data["showas"]]
            display = displayas[tile_data["displayas"]]
            sort = arrangement[tile_data["arrangement"] - 1]

            hash = { path: folder }
            hash[:view] = view unless view == showas.first
            hash[:display] = display unless display == displayas.first
            hash[:sort] = sort unless sort == arrangement.first

            hash.keys.length == 1 ? folder : hash
          end
      end

      config.delete :others if config[:others].empty?

      indent = ENV["TABSIZE"]&.to_i || 2
      output = if json
        JSON.pretty_generate config, indent: " " * indent
      else
        yaml = config.deep_stringify_keys.to_yaml indentation: indent
        yaml.delete_prefix "---\n"
      end

      if args.named.any? then File.write $config, output
      else
        puts output
      end
      return
    end

    config = if $config.end_with? ".json"
      JSON.parse File.read $config
    else
      YAML.load_file $config
    end
    config.deep_symbolize_keys!

    dockutil = dockutil, verbose, "--no-restart"
    dockutil.compact!
    system(*dockutil, *%w[--remove all])

    spacer = %w["" --type spacer]

    config[:apps].each do |app|
      argv = if app.start_with? "space" then spacer
      else
        appdir = Cask::Config.new.appdir
        Dir["{,/System}#{appdir}/**/#{app}.app"]
      end
      system(*dockutil, *%w[--section apps --add], *argv) if argv.any?
    end

    config[:others].each do |other|
      case other
      when String
        argv = other.start_with?("space") ? spacer : other
      else # when Hash
        path, = other.values_at :path, :folder, :url
        options = other.slice :view, :display, :sort, :label
        argv = path, *options.flat_map { |key, value| ["--#{key}", value] }
      end
      system(*dockutil, "--add", *argv)
    end

    puts "Dock loaded from #{$config}" if !args.quiet? && $?.exitstatus.zero?

    exec(*%W[/usr/bin/killall #{verbose} -kill Dock])
  end
end
