# encoding: utf-8

require 'spec_helper'

describe Relation, '#group' do
  include_context 'Project with tasks'

  subject { relation.group(tasks: [:task_id, :task_name]).to_a }

  it { should eql([project_with_tasks]) }
end
