require "rails_helper"

RSpec.describe "CI failure detection" do
  it "テストの失敗をCIに伝える" do
    expect(true).to eq(false)
  end
end