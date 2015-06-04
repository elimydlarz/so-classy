require 'rails_helper'

describe 'topics/index.html.haml', type: :view do

  it 'should contain a list of topics' do
    ruby_topic = Topic.new(name: 'Ruby')
    assign(:topics, [ruby_topic])

    render

    expect(rendered).to include 'Ruby'
  end

  it 'should contain a link to #new' do
    assign(:topics, [])

    render

    assert_select('a[href="/topics/new"]')
  end

end