require_relative 'Author'
require_relative 'Book'
require_relative 'Order'
require_relative 'Reader'
require 'faker'
require 'yaml'

# Library stores all books, readers, authors and orders
class Library
  class << self
    attr_reader :instances
    def write_to_yaml(file_name = 'Library.yml')
      File.new(file_name, 'w') unless File.exist?(file_name)
      File.open(file_name, 'w') do |file|
        file.write(instances.to_yaml)
      end
    end

    def read_from_yaml(file_name = 'Library.yml')
      if File.exist?(file_name)
        @instances = YAML.load_file(file_name)
        puts "There are #{@instances.size} objects is Library."
        @instances
      else
        puts 'There is no such file.'
      end
    end

    def add_instances(elem)
      @instances ||= []
      @instances << elem
    end
  end

  attr_accessor :books, :orders, :authors, :readers

  def initialize(authors = [], books = [], orders = [], readers = [])
    @books = books
    @orders = orders
    @readers = readers
    @authors = authors
    self.class.add_instances(self)
  end

  def write_to_yaml(file_name = "lib_#{self.object_id}.yml")
    File.new(file_name, 'w') unless File.exist?(file_name)
    File.open(file_name, 'w') { |file| file.write(self.to_yaml) }
  end

  def read_from_yaml(file_name = "lib_#{self.object_id}.yml")
    if File.exist?(file_name)
      library = YAML.load_file(file_name)
      @authors = library.authors
      @books = library.books
      @orders = library.orders
      @readers = library.readers
    else
      puts 'There is no such file.'
    end
  end

  def most_popular_reader
    most_popular(1, :reader).first.name
  end

  def count_readers_of_popular_books
    books = most_popular(3, :book)
    set = []
    @orders.each { |order| set << order.reader if (order.book && books).any? }
    set.uniq.length
  end

  def most_popular_book
    most_popular(1, :book).first.title
  end

  def seeds
    @authors = []
    @books = []
    10.times do
      author = Faker::Book.unique.author
      bio = 'Some biography.'
      title = Faker::Book.unique.title
      @authors.push Author.new(author, bio)
      @books.push Book.new(title, author)
    end

    @readers = []
    30.times do
      name = Faker::Name.unique.name
      email = Faker::Internet.email(name)
      city = Faker::Address.city
      street = Faker::Address.street_name
      house = Faker::Address.building_number
      @readers.push(Reader.new(name, email, city, street, house))
    end

    @orders = []
    100.times do
      book_rnd = rand(10)
      reader_rnd = rand(30)
      @orders.push Order.new(@books[book_rnd], @readers[reader_rnd])
    end
  end

  private

  def most_popular(elements_qty, method)
    @orders.group_by(&method)
           .max_by(elements_qty) { |_, value| value.length }
           .to_h.keys
  end
end
