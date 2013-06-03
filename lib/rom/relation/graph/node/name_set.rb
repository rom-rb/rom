module ROM
  module Relation
    class Graph
      class Node

        # Set of relation names for a given relationship
        #
        # @api private
        class NameSet
          include Enumerable

          # Initialize a new node name set
          #
          # @param [ROM::Relationship] relationship
          #   the relationship used to define the set
          #
          # @param [ROM::Mapper::Registry] mapper_registry
          #   the registry containing all mappers
          #
          # @return [undefined]
          #
          # @api private
          def initialize(relationship, mapper_registry)
            @relationship     = relationship
            source_mapper     = mapper_registry[@relationship.source_model]
            @relationship_set = source_mapper.relationships
            @relation_map     = mapper_registry.relation_map
            @node_names       = node_names
          end

          # Iterate on all generated relation node names
          #
          # @return [self]
          #
          # @api private
          def each(&block)
            return to_enum unless block_given?
            @node_names.each(&block)
            self
          end

          # Return the first name
          #
          # @return [Node::Name, Symbol]
          #
          # @api private
          def first
            to_a.first
          end

          # Return the last name
          #
          # @return [Node::Name, Symbol]
          #
          # @api private
          def last
            to_a.last
          end

          private

          # Generates an array of unique relation node names used to build a join
          #
          # @return [Array<Node::Name>]
          #
          # @api private
          def node_names
            rel_map.each_with_object([]) { |(right_name, relationship), names|
              names << Name.new(left_name(names), right_name, relationship)
            }
          end

          # Generate pairs of [target relation name, relationship]
          #
          # [:song_tags,      Song#song_tags    ] => :songs_X_song_tags
          # [:tags,           SongTag#tag       ] => :songs_X_song_tags_X_tags
          # [:infos,          Tag#infos         ] => :songs_X_song_tags_X_infos
          # [:infos_contents, Info#info_contents] => :songs_X_song_tags_X_infos_X_info_contents
          #
          # @return [Array<(Symbol, Relationship)>]
          #
          # @api private
          def rel_map(rel = @relationship, rels = [], via_rel = @relationship)
            if through_rel = @relationship_set[rel.through]
              rel_map(through_rel, rels, via_relationship(through_rel))
            end

            via_rel = via_relationship(via_rel) if target_relationship?(via_rel)

            rels << [ right_name(rel), via_rel ]
          end

          def via_relationship(rel)
            return rel unless rel.respond_to?(:via_relationship)
            rel.via_relationship || rel
          end

          def left_name(names)
            names.last || left_relation_name(@relationship)
          end

          def right_name(rel)
            target_name?(rel) ? rel.name : name(rel)
          end

          def name(rel)
            rel.operation ? rel.name : right_relation_name(rel)
          end

          def left_relation_name(rel)
            @relation_map[rel.source_model]
          end

          def right_relation_name(rel)
            @relation_map[rel.target_model]
          end

          def target_name?(rel)
            rel.operation && target_relationship?(rel)
          end

          def target_relationship?(rel)
            @relationship == rel
          end

        end # class NameSet

      end # class Node
    end # class Graph
  end # module Relation
end # module ROM
