require 'test_helper'
require "propshaft/asset"
require "propshaft/load_path"

class FontAwesomePropshaftRailsTest < ActionDispatch::IntegrationTest

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

  test "sass import compiles correctly" do
    asset = Rails.application.assets.load_path.find("sass-import.css.sass")
    assert asset, "sass-import.css.sass not found in Propshaft load path"

    source = File.read(asset.path)
    engine = SassC::Engine.new(
      source,
      syntax: :sass,
      load_paths: Rails.application.config.assets.paths
    )

    css = engine.render
    assert_match(/font-family:\s*'FontAwesome';/, css, "sass-import.css.sass missing FontAwesome styles")
  rescue SassC::SyntaxError => e
    flunk "sass-import.css.sass failed to compile: #{e.message}"
  end

  test "scss import compiles correctly" do
    asset = Rails.application.assets.load_path.find("scss-import.css.scss")
    assert asset, "scss-import.css.scss not found in Propshaft load path"

    source = File.read(asset.path)
    engine = SassC::Engine.new(
      source,
      syntax: :scss,
      load_paths: Rails.application.config.assets.paths
    )

    css = engine.render
    assert_match(/font-family:\s*'FontAwesome';/, css, "scss-import.css.scss missing FontAwesome styles")
  rescue SassC::SyntaxError => e
    flunk "scss-import.css.scss failed to compile: #{e.message}"
  end

  test "helpers should be available in the view" do
    get "/icons"
    assert_response :success
    assert_select "i.fa.fa-flag"
    assert_select "span.fa-stack"
  end
end
