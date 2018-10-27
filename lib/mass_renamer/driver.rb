require 'pathname'
require 'tempfile'

module MassRenamer

  class Filesystem_Driver

    def initialize ask: , dry:, verbose:, no_delete:, force:
      @ask = ask
      @dry = dry
      @verbose = verbose
      @no_delete = no_delete
      @force = force
    end

    def ask msg, from, to = nil
      print "#{msg} '#{from}'#{to ? " -> '#{to}'" : '' }? [YN]: "
      gets.chomp.downcase == ?y
    end

    def overwrite to
      loop do
        print "Overwrite #{to}? [Y(es)/N(o)/A(bort)]: "
        case gets.chomp.downcase
        when ?a
          puts "Aborting."
          return :abort
        when ?y
          return :yes
        when ?n
          puts "Not overwriting, skipping."
          return :no
        else
          puts "Unexpected answer, try again."
        end
      end

    end

    def remove! from
      raise "Deletes were disables." if @no_delete
      begin
        puts "rm -r '#{from}'" if @dry or @verbose
        if @ask
          return unless ask("Remove file", from)
        end
        return if @dry
        FileUtils.remove_entry from
      rescue StandardError => e
        STDERR.puts "remove of '#{from}' failed: #{e.message}"
        raise
      end
    end

    def copy! from, to
      begin
        puts "cp -r '#{from}' '#{to}'" if @dry or @verbose
        if @ask
          return unless ask("Copy", from, to)
        end
        return if @dry
        if File.exist?(to) and not @force
          case overwrite(to)
          when :abort
            exit 1
          when :no
            return
          when :yes
          end
        end
        FileUtils.mkdir_p File.dirname(to)
        FileUtils.copy_entry from, to, preserve: true, remove_destination: true
      rescue StandardError => e
        STDERR.puts "copy '#{from}' -> '#{to}' failed: #{e.message}"
        raise
      end
    end

    def move! from, to
      begin
        puts "mv '#{from}' '#{to}'" if @dry or @verbose
        if @ask
          return unless ask("Move", from, to)
        end
        return if @dry
        if File.exist?(to) and not @force
          case overwrite(to)
          when :abort
            exit 1
          when :no
            return
          when :yes
          end
        end
        FileUtils.mkdir_p File.dirname(to)
        File.rename from, to
      rescue StandardError => e
        STDERR.puts "move '#{from}' -> '#{to}' failed: #{e.message}"
        raise
      end
    end

  end

  class Driver
    include Free

    def initialize opts
      @opts = opts
      validate_environment!
    end

    def rename!
      files = gather_files(
        @opts[:dir],
        recursive: @opts[:recursive],
        filter: @opts[:filter]
      )
      renames = invoke_editor files
      do_renames! renames
    end

    def do_renames! renames
      fd = Filesystem_Driver.new(
        ask: @opts[:ask],
        dry: @opts[:dry],
        verbose: @opts[:verbose],
        no_delete: @opts[:no_delete],
        force: @opts[:force]
      )

      renames.each do |from, to|
        from = File.expand_path from
        to.map!(&File.method(:expand_path))

        begin
          case to.length
          when 0
            fd.remove! from
          when 1
            to = to.first
            next if from == to
            fd.move! from, to
          else
            to.each { |dst| fd.copy! from, dst unless from == dst }
            fd.remove! from unless to.include? from
          end
        rescue
          next if @opts[:keep_going]
          STDERR.puts "Something failed, stopping."
          exit 1
        end
      end
    end

    def invoke_editor files
      tmpfile = Tempfile.new
      begin
        tmpfile.write generate_file_to_edit(files)
        tmpfile.close
        unless system(@opts[:editor], tmpfile.path)
          raise "Cannot open editor (not in path?). Fix it."
        end
        tmpfile.open
        parse_renames(tmpfile.read)
      ensure
        tmpfile.close
        tmpfile.unlink
      end
    end

    def validate_environment!
      raise IOError, "Directory does not exist." unless File.exist? @opts[:dir]
    end

  end
end
