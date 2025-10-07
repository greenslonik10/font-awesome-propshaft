require 'test_helper'
require "propshaft/asset"
require "propshaft/load_path"
require "open3"

class FontAwesomePropshaftRailsTest < ActionDispatch::IntegrationTest

  setup do
    @project_root = File.expand_path("..", __dir__)

    @app_styles   = File.join(@project_root, "app", "assets", "stylesheets")
    @dummy_styles = File.join(@project_root, "test", "dummy", "app", "assets", "stylesheets")
    @builds_dir   = File.join(@project_root, "test", "dummy", "app", "assets", "builds")

    FileUtils.mkdir_p(@builds_dir)
  end

  teardown do
    if Dir.exist?(@builds_dir)
      Dir.glob(File.join(@builds_dir, "*")).each do |file|
        FileUtils.rm_rf(file)
      end
    end
  end

  test "engine is loaded" do
    assert_equal ::Rails::Engine, FontAwesomePropshaft::Rails::Engine.superclass
  end

  test "fonts are available in propshaft" do
    %w[
      fa-brands-400.ttf
      fa-brands-400.woff2
      fa-regular-400.ttf
      fa-regular-400.woff2
      fa-solid-900.ttf
      fa-solid-900.woff2
      fa-v4compatibility.ttf
      fa-v4compatibility.woff2
    ].each do |font_file|
      asset = Rails.application.assets.load_path.find(font_file)
      assert asset, "#{font_file} not found in Propshaft load path"
    end
  end

  test "stylesheets contain asset pipeline references to fonts" do
    asset = Rails.application.assets.load_path.find("font-awesome-propshaft.css")
    assert asset, "font-awesome-propshaft.css not found in Propshaft load path"

    css = File.read(asset.path)

    %w[
      fa-brands-400
      fa-regular-400
      fa-solid-900
      fa-v4compatibility
    ].each do |font|
      %w[.ttf .woff2].each do |ext|
        assert_match %r{/#{font}(-\w+)?#{ext}}, css, "CSS does not reference #{font}#{ext}"
      end
    end
  end

  test "stylesheets are served" do
    asset = Rails.application.assets.load_path.find("font-awesome-propshaft.css")
    assert asset, "font-awesome-propshaft.css not found in Propshaft load path"

    css = File.read(asset.path)
    assert_match(/font-family:\s*'FontAwesome';/, css)
  end

  test "SASS and SCSS imports compile correctly with DartSass" do
    {
      "sass-import.css.sass"   => "sass-import.css",
      "scss-import.css.scss"   => "scss-import.css"
    }.each do |src_file, out_file|
      source = File.join(@dummy_styles, src_file)  
      output = File.join(@builds_dir, out_file)    

      cmd = [
        "bundle", "exec", "dartsass",
        "#{source}:#{output}",
        "--load-path", @app_styles,
        "--load-path", @dummy_styles
      ]

      stdout, stderr, status = nil
      Dir.chdir(@project_root) do
        stdout, stderr, status = Open3.capture3(*cmd)
      end

      unless status.success?
        message = <<~MSG
          DartSass compilation failed for #{src_file}
          Exit status: #{status && status.exitstatus}
          Command: #{cmd.join(" ")}
          STDOUT:
          #{stdout.to_s.strip.empty? ? "(empty)" : stdout}
          STDERR:
          #{stderr.to_s.strip.empty? ? "(empty)" : stderr}
        MSG

        flunk message
      end

      assert File.exist?(output), "Compiled #{out_file} not found at #{output}"

      css = File.read(output)
      assert_match(/font-family:\s*["']?FontAwesome["']?;/, css, "FontAwesome styles missing or formatted differently in #{out_file}")
    end
  end

  test "helpers should be available in the view" do
    get "/icons"
    assert_response :success
    assert_select "i.fa.fa-flag"
    assert_select "span.fa-stack"
  end
end
