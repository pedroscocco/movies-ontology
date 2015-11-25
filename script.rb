require 'set'
require 'i18n'

I18n.config.available_locales = :en

@actor_printed = false
def get_actor_name actor
  first, family = actor.split(', ').reverse
  return actor if family.nil?
  match = first.match(/(\w*)( [^()]*)?(\([IVX]*\))?/)
  first = match[1]
  middle = match[2].strip if match[2] != nil
  [first, middle, family]
end

def print_actor actor
  first, middle, family = get_actor_name actor
  first = first.strip.gsub(" ", "_")
  family = family.strip.gsub(" ", "_") if !family.nil?
  if middle != nil
    middle = middle.strip.gsub(" ", "_")
    full_name = first + '_' + middle + '_' + family
  elsif family != nil
    full_name = first + '_' + family
  else
    full_name = first
  end
  return full_name if @actor_printed
  @actor_printed = true

  puts "<Declaration>\n  <NamedIndividual IRI=\"##{full_name}\"/>\n</Declaration>\n\n"
  puts "<ClassAssertion>\n  <Class IRI=\"#Director\"/>\n  <NamedIndividual IRI=\"##{full_name}\"/>\n</ClassAssertion>\n\n"
  puts "<DataPropertyAssertion>\n  <DataProperty IRI=\"#familyName\"/>\n  <NamedIndividual IRI=\"##{full_name}\"/>\n  <Literal datatypeIRI=\"&xsd;string\">#{family}</Literal>\n</DataPropertyAssertion>\n\n"  if !family.nil?
  puts "<DataPropertyAssertion>\n  <DataProperty IRI=\"#firstName\"/>\n  <NamedIndividual IRI=\"##{full_name}\"/>\n  <Literal datatypeIRI=\"&xsd;string\">#{first}</Literal>\n</DataPropertyAssertion>\n\n"
  return full_name
end

def print_owl actor, movie
  full_name = print_actor actor
  movie = movie.rpartition(' ')[0]
  movie.gsub!(" ", "_")
  puts "<ObjectPropertyAssertion>\n  <ObjectProperty IRI=\"#directed\"/>\n  <NamedIndividual IRI=\"##{full_name}\"/>\n  <NamedIndividual IRI=\"##{movie}\"/>\n</ObjectPropertyAssertion>\n\n"
end


ACTOR_MOVIE = /^([^\t]*)\t*(.* \(([0-9]{4})(\/[IVX]*)?\))/
ONLY_MOVIE = /\t\t\t(.* \(([0-9]{4})(\/[IVX]*)?\))/


movies = Set.new File.read('filmes.txt').each_line.to_a.map(&:strip) # { |e| I18n.transliterate(e.strip)}

if !File.exist?('movies.owl')
  movies_file = File.open('movies.owl', 'a')
  movies.each do |movie|
    match = movie.match(/(.*) \(([0-9]{4})(\/[IVX]*)?\)/)
    puts movie if match == nil
    name = match[1].gsub(' ', '_')
    date = match[2]
    movies_file.write("<Declaration>\n  <NamedIndividual IRI=\"##{name}\"/>\n</Declaration>\n\n")
    movies_file.write("<ClassAssertion>\n  <Class IRI=\"#Movie\"/>\n  <NamedIndividual IRI=\"##{name}\"/>\n</ClassAssertion>\n\n")
    movies_file.write("<DataPropertyAssertion>\n  <DataProperty IRI=\"#release_year\"/>\n  <NamedIndividual IRI=\"##{name}\"/>\n  <Literal datatypeIRI=\"&xsd;int\">#{date}</Literal>\n</DataPropertyAssertion>\n\n")
  end
end
                 #actresses
file = File.open('directors.list', 'r')
current_actor = nil
movie = nil
file.each do |line|
  # I18n.transliterate(line)
  next if line.length <= 2
  line.force_encoding('ISO-8859-1')
  if line[0] == "\t"
    match = ONLY_MOVIE.match(line)
    next if match == nil
    movie = match[1]
  else
    match = ACTOR_MOVIE.match(line)
    next if match == nil
    current_actor = match[1]
    @actor_printed = false
    movie = match[2]
  end
  next if line.include?("VG") || line.include?("TV") || line.include?("V")
  next if movie == nil && current_actor == nil
  if movies.include? movie
    print_owl current_actor, movie
  end
end