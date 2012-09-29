{ Datomic } = require src + 'datomic'
{ edn, find, f } = require src + 'edn'
schema = require './schema'

describe 'Sample with movies', ->

  imdb = new Datomic 'localhost', 8888, 'db', 'imdb'

  add_movie = (id, title, rating, done) -> imdb.transact [
    [':db/add', id, ':title', title]
    [':db/add', id, ':rating', rating]
  ], -> done()

  before (done) ->
    
    imdb.createDatabase ->
      imdb.transact schema.movies, ->
        add_movie 1, 'pulp fiction', 8.9, ->
          add_movie 2, 'fight club', 8.8, ->
            add_movie 3, 'lola rennt', 7.9, ->
              add_movie 4, 'trainspotting', 8.2, ->
                done()

  it 'should return all', (done) ->

    imdb.q [':find', '?m', ':where', ['?m', ':title']], (err, movies)->
      movies.length.should.equal 4
      done()
    
  it 'should find trainspotting', (done) ->
    
    imdb.q find('?m').where('?m', ':title', 'trainspotting'), (err, movies) ->
      imdb.entity movies[0][0], (err, movie) ->
        movie.title.should.equal 'trainspotting'
        done()
  
  it 'should find the highest movie over 8.8', (done) ->
    
    imdb.q [
      ':find'
      '?t'
      ':where'
      ['?m', ':rating', '?r']
      ['?m', ':title', '?t']
      [f '>', '?r', 8.8]
    ], (err, movies) ->
    #    imdb.q find('?r').where(
    #  ['?m', ':rating', '?r']
    #  ['?m2', ':rating', '?r2']
    #  -> ['>', '?r', '?r2']
    #), (err, movies) ->
      movies[0][0].should.equal 'pulp fiction'
      done()
  
