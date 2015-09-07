class SongSerializer < ActiveModel::Serializer
  attributes :id, :title, :audio_url, :album_art, :artist, :genre
end
