require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = User.new(
      email: "profile-test@example.com",
      password: "password123"
    )
  end

  test "プロフィール項目は空欄でも有効である" do
    @user.assign_attributes(name: "", residence: "", bio: "")

    assert @user.valid?, @user.errors.full_messages.join(", ")
  end

  test "プロフィール項目は文字数の上限まで入力できる" do
    @user.assign_attributes(
      name: "あ" * 30,
      residence: "あ" * 50,
      bio: "あ" * 500
    )

    assert @user.valid?, @user.errors.full_messages.join(", ")
  end

  test "プロフィール項目が文字数の上限を超えると無効である" do
    { name: 30, residence: 50, bio: 500 }.each do |attribute, limit|
      user = @user.dup
      user.public_send("#{attribute}=", "あ" * (limit + 1))

      assert_not user.valid?, "#{attribute}が上限を超えても有効になっています"
      assert user.errors.of_kind?(attribute, :too_long),
             "#{attribute}に文字数超過のエラーがありません"
    end
  end
end
