require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "is valid with a name and slug" do
    organization = Organization.new(
      name: "OpsPilot",
      slug: "opspilot"
    )

    assert organization.valid?
  end

  test "requires a name" do
    organization = Organization.new(
      name: nil,
      slug: "opspilot"
    )

    assert_not organization.valid?
    assert_includes organization.errors[:name], "can't be blank"
  end

  test "requires a slug" do
    organization = Organization.new(
      name: "OpsPilot",
      slug: nil
    )

    assert_not organization.valid?
    assert_includes organization.errors[:slug], "can't be blank"
  end

  test "requires a unique slug" do
    Organization.create!(
      name: "First Organization",
      slug: "shared-slug"
    )

    duplicate = Organization.new(
      name: "Second Organization",
      slug: "shared-slug"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end
end
