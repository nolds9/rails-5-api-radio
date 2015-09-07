require 'test_helper'

class SongsControllerTest < ActionController::TestCase
  setup do
    @song = songs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should create song" do
    assert_difference('Song.count') do
      post :create, params: { song: { album_art: @song.album_art, artist: @song.artist, audio_url: @song.audio_url, genre: @song.genre, title: @song.title } }
    end

    assert_response 201
  end

  test "should show song" do
    get :show, params: { id: @song }
    assert_response :success
  end

  test "should update song" do
    patch :update, params: { id: @song, song: { album_art: @song.album_art, artist: @song.artist, audio_url: @song.audio_url, genre: @song.genre, title: @song.title } }
    assert_response 200
  end

  test "should destroy song" do
    assert_difference('Song.count', -1) do
      delete :destroy, params: { id: @song }
    end

    assert_response 204
  end
end
