# frozen_string_literal: true

require 'spec_helper'

module Pronto
  # rubocop:disable Metrics/BlockLength
  describe Cpplint do
    let(:cpplint) { Cpplint.new(patches) }
    let(:patches) { [] }
    describe '#executable' do
      subject(:executable) { cpplint.executable }

      it 'is `cpplint` by default' do
        expect(executable).to eql('cpplint')
      end
    end

    describe 'parsing' do
      it 'filtering CPP files' do
        files = %w[
          test.py
          test.c test.c++ test.cc test.cu test.cuh test.icc
          test.g
          test.h++ test.hpp test.hxx test.hh test.cxx test.cpp
          test.rb
        ]

        exp = cpplint.filter_cpp_files(files)
        expect(exp).to eq(%w[
                            test.c test.c++ test.cc test.cu test.cuh
                            test.icc test.h++ test.hpp test.hxx test.hh
                            test.cxx test.cpp
                          ])
      end

      it 'parses a linter output to a map' do
        # rubocop:disable Layout/LineLength
        executable_output = [
          'test1.cpp:0: No copyright message found.  You should have a line: "Copyright [year] <Copyright Owner>"  [legal/copyright] [5]',
          'test2.cpp:4: { should almost always be at the end of the previous line  [whitespace/braces] [4]'
        ].join("\n")
        act = cpplint.parse_output(executable_output)
        exp = [
          {
            file_path: 'test1.cpp',
            line_number: 0,
            column_number: 0,
            message: 'cpplint: No copyright message found.  You should have a line: "Copyright [year] <Copyright Owner>"  [legal/copyright] [5]',
            level: 'warning'

          },
          {
            file_path: 'test2.cpp',
            line_number: 4,
            column_number: 0,
            message: 'cpplint: { should almost always be at the end of the previous line  [whitespace/braces] [4]',
            level: 'warning'
          }
        ]
        # rubocop:enable Layout/LineLength
        expect(act).to eq(exp)
      end
    end

    describe '#run' do
      around(:example) do |example|
        create_repository
        Dir.chdir(repository_dir) do
          example.run
        end
        delete_repository
      end

      let(:patches) { Pronto::Git::Repository.new(repository_dir).diff('master') }

      context 'patches are nil' do
        let(:patches) { nil }

        it 'returns an empty array' do
          expect(cpplint.run).to eql([])
        end
      end

      context 'no patches' do
        let(:patches) { [] }

        it 'returns an empty array' do
          expect(cpplint.run).to eql([])
        end
      end

      context 'with patch data' do
        before(:each) do
          function_use = <<-PASTFILE
          // nothing
          PASTFILE

          add_to_index('test.cpp', function_use)
          create_commit
        end

        context 'with error in changed file' do
          before(:each) do
            create_branch('staging', checkout: true)

            updated_function_def = <<-NEWFILE
            int foo(int b){ return b+1;}
            NEWFILE

            add_to_index('best.cpp', updated_function_def)

            create_commit
            ENV['PRONTO_CPPLINT_OPTS'] = ''
          end

          it 'returns correct error message' do
            run_output = cpplint.run
            expect(run_output.count).to eql(1)
            expect(run_output[0].msg).to eql('cpplint: Missing space before {  [whitespace/braces] [5]')
          end
        end
      end
    end
  end
  # rubocop:enable Metrics/BlockLength
end
