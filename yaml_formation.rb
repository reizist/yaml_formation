#!/usr/bin/env ruby

require 'json'
require 'yaml'
require 'fileutils'

class YamlFormation
  attr_reader :file_path, :yml_dir_path

  def initialize
    current_time = Time.now.strftime('%Y%m%d%H%M%S')
    @json_path = File.expand_path("../tmp/yamlformation/make_stack_#{current_time}.json", File.dirname(__FILE__))
    @yml_dir_path = File.expand_path("../datas/yml", File.dirname(__FILE__))
  end

  def merge_yaml(yaml1, yaml2)
    yaml2.each do |key, value|
      if value.class == Hash && yaml1.key?(key)
        yaml1[key] = merge_yaml(yaml1[key], value)
      else
        yaml1[key] = value
      end
    end
    yaml1
  end

  def make_union_yaml(dir)
    merged_yaml = {}
    Dir.glob("#{dir}/*.yml").each do |file|
      yaml = YAML.load_file(file)
      merged_yaml = merge_yaml(merged_yaml, yaml)
    end

    merged_yaml.to_yaml
  end

  def json2yml(json)
    JSON.parse(json).to_yaml
  end

  def yml2json(yml)
    YAML::load(yml).to_json
  end

  def make_new_json
    File.open(@json_path, "w").close
  end

  def run
    begin
      make_new_json
      File.open(@json_path, "w").write(yml2json(make_union_yaml(yml_dir_path)))
      puts "#{@json_path} created."
    rescue => e
      FileUtils.rm @json_path
      puts "#{e.message} - #{e.backtrace}"
    end
  end
end

YamlFormation.new.run
