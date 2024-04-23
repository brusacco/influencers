# frozen_string_literal: true

require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
# frozen_string_literal: true

require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  def setup
    @profile = profiles(:one)
  end

  test "should have one attached avatar" do
    assert_respond_to @profile, :avatar
  end

  test "should have serialized data" do
    assert_respond_to @profile, :data
    assert_instance_of Hash, @profile.data
  end

  test "should have many instagram posts" do
    assert_respond_to @profile, :instagram_posts
    assert @profile.instagram_posts.empty?
  end

  test "should have profile types" do
    assert_respond_to @profile, :profile_type
    assert_equal %i[hombre mujer marca medio estatal memes programa], Profile.profile_types.keys
  end

  test "should have collaborated collaborations" do
    assert_respond_to @profile, :collaborated_collaborations
    assert @profile.collaborated_collaborations.empty?
  end

  test "should have collaborated profiles" do
    assert_respond_to @profile, :collaborated
    assert @profile.collaborated.empty?
  end

  test "should have collaborator collaborations" do
    assert_respond_to @profile, :collaborator_collaborations
    assert @profile.collaborator_collaborations.empty?
  end

  test "should have collaborators" do
    assert_respond_to @profile, :collaborators
    assert @profile.collaborators.empty?
  end

  test "should validate uniqueness of username" do
    assert @profile.valid?
    duplicate_profile = @profile.dup
    assert_not duplicate_profile.valid?
    assert_equal ["has already been taken"], duplicate_profile.errors[:username]
  end

  test "should update profile after create" do
    assert_changes -> { @profile.updated_at } do
      Profile.create(username: "new_username")
    end
  end

  test "should clear cache after update" do
    assert_changes -> { @profile.updated_at } do
      @profile.update(username: "new_username")
    end
  end

  test "should clear cache after touch" do
    assert_changes -> { @profile.updated_at } do
      @profile.touch
    end
  end

  test "should have paraguayos scope" do
    assert_respond_to Profile, :paraguayos
    assert_equal [@profile], Profile.paraguayos.to_a
  end

  test "should have otros scope" do
    assert_respond_to Profile, :otros
    assert_equal [], Profile.otros.to_a
  end

  test "should have no_country scope" do
    assert_respond_to Profile, :no_country
    assert_equal [], Profile.no_country.to_a
  end

  test "should have no_profile_type scope" do
    assert_respond_to Profile, :no_profile_type
    assert_equal [], Profile.no_profile_type.to_a
  end

  test "should have micro scope" do
    assert_respond_to Profile, :micro
    assert_equal [], Profile.micro.to_a
  end

  test "should have ransackable attributes" do
    assert_respond_to Profile, :ransackable_attributes
    assert_equal %w[
      created_at
      data
      id
      updated_at
      username
      category_name
      is_private
      is_business_account
      followers
      biography
      country
      profile_type
    ], Profile.ransackable_attributes
  end

  test "should have empty ransackable associations" do
    assert_respond_to Profile, :ransackable_associations
    assert_empty Profile.ransackable_associations
  end

  test "should return related brands" do
    assert_respond_to @profile, :related_brands
    assert_equal [], @profile.related_brands
  end

  test "should return mentions" do
    assert_respond_to @profile, :mentions
    assert_equal [], @profile.mentions
  end

  test "should return collaborations hash" do
    assert_respond_to @profile, :collaborations_hash
    assert_equal [], @profile.collaborations_hash
  end

  test "should save avatar" do
    assert_respond_to @profile, :save_avatar
    assert_nothing_raised do
      @profile.save_avatar
    end
  end

  test "should update profile stats" do
    assert_respond_to @profile, :update_profile_stats
    assert_nothing_raised do
      @profile.update_profile_stats
    end
  end

  test "should update profile" do
    assert_respond_to @profile, :update_profile
    assert_nothing_raised do
      @profile.update_profile
    end
  end

  test "should clear cache" do
    assert_respond_to @profile, :clear_cache
    assert_nothing_raised do
      @profile.clear_cache
    end
  end
end
