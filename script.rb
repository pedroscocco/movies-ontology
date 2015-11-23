ACTOR_MOVIE = /^([^\t]*)\t*(.* \(([0-9]{4}|[?]{4})(\/[IVX]*)?\))/
ONLY_MOVIE = /\t\t\t(.* \(([0-9]{4}|[?]{4})(\/[IVX]*)?\))/

movies = File.read('filmes.txt').each_line.to_a.map(&:strip)

file = File.open('actors.list', 'r')
dest = File.open('result.txt', 'a')
current_actor = nil
movie = nil
file.each do |line|
  next if line.length <= 2
  line.force_encoding('ISO-8859-1')
  if line[0] == "\t"
    match = ONLY_MOVIE.match(line)
    puts line if match == nil
    next if match == nil
    movie = match[1]
  else
    match = ACTOR_MOVIE.match(line)
    puts line if match == nil
    next if match == nil
    current_actor = match[1]
    movie = match[2]
  end
  if movie != nil && current_actor != nil && movie == "Captain America: The Winter Soldier (2014)"
    dest.write(current_actor + "\n")
  end
end

/\(([0-9]{4}(\\[IVX]*)?|[?]{4})\)/