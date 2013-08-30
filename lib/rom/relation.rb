# encoding: utf-8

module ROM

  # Enhanced ROM relation wrapping axiom relation and using injected mapper to
  # load/dump tuples/objects
  #
  # @example
  #
  #   # set up an axiom relation
  #   header = [[:id, Integer], [:name, String]]
  #   data   = [[1, 'John'], [2, 'Jane']]
  #   axiom  = Axiom::Relation.new(header, data)
  #
  #   # provide a simple mapper
  #   class Mapper < Struct.new(:header)
  #     def load(tuple)
  #       data = header.map { |attribute|
  #         [attribute.name, tuple[attribute.name]]
  #       }
  #       Hash[data]
  #     end
  #
  #     def dump(hash)
  #       header.each_with_object([]) { |attribute, tuple|
  #         tuple << hash[attribute.name]
  #       }
  #     end
  #   end
  #
  #   # wrap axiom relation with ROM relation
  #   mapper   = Mapper.new(axiom.header)
  #   relation = ROM::Relation.new(axiom, mapper)
  #
  #   # relation is an enumerable and it uses mapper to load/dump tuples/objects
  #   relation.to_a
  #   # => [{:id=>1, :name=>'John'}, {:id=>2, :name=>'Jane'}]
  #
  #   # you can insert/update/delete objects
  #   relation.insert(id: 3, name: 'Piotr').to_a
  #   # => [{:id=>1, :name=>"John"}, {:id=>2, :name=>"Jane"}, {:id=>3, :name=>"Piotr"}]
  #
  #   relation.delete(id: 1, name: 'John').to_a
  #   # => [{:id=>2, :name=>"Jane"}]
  #
  class Relation
    include Enumerable, Concord::Public.new(:relation, :mapper)

    # Build a new relation
    #
    # @param [Axiom::Relation]
    # @param [Object] mapper
    #
    # @return [Relation]
    #
    # @api public
    def self.build(relation, mapper)
      new(mapper.call(relation).optimize, mapper)
    end

    # Iterate over tuples yielded by the wrapped relation
    #
    # @example
    #   mapper = Class.new {
    #     def load(value)
    #       value.to_s
    #     end
    #
    #     def dump(value)
    #       value.to_i
    #     end
    #   }.new
    #
    #   relation = ROM::Relation.new([1, 2, 3], mapper)
    #
    #   relation.each do |value|
    #     puts value # => '1'
    #   end
    #
    # @yieldparam [Object]
    #
    # @return [Relation]
    #
    # @api public
    def each
      return to_enum unless block_given?
      relation.each { |tuple| yield(mapper.load(tuple)) }
      self
    end

    # Insert an object into relation
    #
    # @example
    #   axiom    = Axiom::Relation.new([[:id, Integer]], [[1], [2]])
    #   relation = ROM::Relation.new(axiom, mapper)
    #
    #   relation.insert(id: 3)
    #   relation.to_a # => [[1], [2], [3]]
    #
    # @param [Object]
    #
    # @return [Relation]
    #
    # @api public
    def insert(object)
      new(relation.insert([mapper.dump(object)]))
    end
    alias_method :<<, :insert

    # Update an object
    #
    # @example
    #   data     = [[1, 'John'], [2, 'Jane']]
    #   axiom    = Axiom::Relation.new([[:id, Integer], [:name, String]], data)
    #   relation = ROM::Relation.new(axiom, mapper)
    #
    #   relation.update({id: 2, name: 'Jane Doe'}, {id:2, name: 'Jane'})
    #   relation.to_a # => [[1, 'John'], [2, 'Jane Doe']]
    #
    # @param [Object]
    # @param [Hash] original attributes
    #
    # @return [Relation]
    #
    # @api public
    def update(object, original_tuple)
      new(relation.delete([original_tuple]).insert([mapper.dump(object)]))
    end

    # Delete an object from the relation
    #
    # @example
    #   axiom    = Axiom::Relation.new([[:id, Integer]], [[1], [2]])
    #   relation = ROM::Relation.new(axiom, mapper)
    #
    #   relation.delete(id: 1)
    #   relation.to_a # => [[2]]
    #
    # @param [Object]
    #
    # @return [Relation]
    #
    # @api public
    def delete(object)
      new(relation.delete([mapper.dump(object)]))
    end

    # Replace all objects in the relation with new ones
    #
    # @example
    #   axiom    = Axiom::Relation.new([[:id, Integer]], [[1], [2]])
    #   relation = ROM::Relation.new(axiom, mapper)
    #
    #   relation.replace([{id: 3}, {id: 4}])
    #   relation.to_a # => [[3], [4]]
    #
    # @param [Array<Object>]
    #
    # @return [Relation]
    #
    # @api public
    def replace(objects)
      new(relation.replace(objects.map(&mapper.method(:dump))))
    end

    # Restrict the relation
    #
    # @example
    #   axiom    = Axiom::Relation.new([[:id, Integer]], [[1], [2]])
    #   relation = ROM::Relation.new(axiom, mapper)
    #
    #   relation.restrict(id: 2).to_a # => [[2]]
    #
    # @param [Hash] conditions
    #
    # @return [Relation]
    #
    # @api public
    def restrict(*args, &block)
      new(relation.restrict(*args, &block))
    end

    # Take objects form the relation with provided limit
    #
    # @example
    #   axiom    = Axiom::Relation.new([[:id, Integer]], [[1], [2]])
    #   relation = ROM::Relation.new(axiom, mapper)
    #
    #   relation.take(2).to_a # => [[2]]
    #
    # @param [Integer] limit
    #
    # @return [Relation]
    #
    # @api public
    def take(limit)
      new(sorted.take(limit))
    end

    # Take first n-objects from the relation
    #
    # @example
    #   axiom    = Axiom::Relation.new([[:id, Integer]], [[1], [2]])
    #   relation = ROM::Relation.new(axiom, mapper)
    #
    #   relation.first.to_a # => [[1]]
    #   relation.first(2).to_a # => [[1], [2]]
    #
    # @param [Integer]
    #
    # @return [Relation]
    #
    # @api public
    def first(limit = 1)
      new(sorted.first(limit))
    end

    # Take last n-objects from the relation
    #
    # @example
    #   axiom    = Axiom::Relation.new([[:id, Integer]], [[1], [2]])
    #   relation = ROM::Relation.new(axiom, mapper)
    #
    #   relation.last.to_a # => [[2]]
    #   relation.last(2).to_a # => [[1], [2]]
    #
    # @param [Integer] limit
    #
    # @return [Relation]
    #
    # @api public
    def last(limit = 1)
      new(sorted.last(limit))
    end

    # Drop objects from the relation by the given offset
    #
    # @example
    #   axiom    = Axiom::Relation.new([[:id, Integer]], [[1], [2]])
    #   relation = ROM::Relation.new(axiom, mapper)
    #
    #   relation.drop(1).to_a # => [[2]]
    #
    # @param [Integer]
    #
    # @return [Relation]
    #
    # @api public
    def drop(offset)
      new(sorted.drop(offset))
    end

    # Sort the relation by provided attributes
    #
    # @example
    #   axiom    = Axiom::Relation.new([[:id, Integer]], [[2], [1]])
    #   relation = ROM::Relation.new(axiom, mapper)
    #
    #   relation.sort_by(:id).to_a # => [[1], [2]]
    #
    # @param [Array<Symbol>]
    #
    # @return [Relation]
    #
    # @api public
    def sort_by(*args, &block)
      new(relation.sort_by(*args, &block))
    end

    # Return exactly one object matching criteria or raise an error
    #
    # @example
    #   axiom    = Axiom::Relation.new([[:id, Integer]], [1]])
    #   relation = ROM::Relation.new(axiom, mapper)
    #
    #   relation.one.to_a # => {id: 1}
    #
    # @param [Proc] block
    #   optional block to call in case no tuple is returned
    #
    # @return [Object]
    #
    # @raise NoTuplesError
    #   if no tuples were returned
    #
    # @raise ManyTuplesError
    #   if more than one tuple was returned
    #
    # @api public
    def one(&block)
      block  ||= ->() { raise NoTuplesError }
      tuples   = take(2).to_a

      if tuples.count > 1
        raise ManyTuplesError
      else
        tuples.first || block.call
      end
    end

    # Inject a new mapper into this relation
    #
    # @example
    #
    #   relation = ROM::Relation.new([], mapper)
    #   relation.inject_mapper(new_mapper)
    #
    # @param [Object] a mapper object
    #
    # @return [Relation]
    #
    # @api public
    def inject_mapper(mapper)
      new(relation, mapper)
    end

    private

    # Sort wrapped relation using all attributes in the header
    #
    # @return [Axiom::Relation]
    #
    # @api private
    def sorted
      relation.sort
    end

    # Return new relation instance
    #
    # @return [Relation]
    #
    # @api private
    def new(new_relation, new_mapper = mapper)
      self.class.new(new_relation, new_mapper)
    end

  end # class Relation

end # module ROM
