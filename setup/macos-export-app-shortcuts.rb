#!/usr/bin/ruby
require 'json'
require 'shellwords'
require 'tempfile'

Key = 'NSUserKeyEquivalents'

def read_NSUserKeyEquivalents(domain)
   Tempfile.open(domain) do |f|
      f.close
      Process.wait spawn(*%W|defaults read #{domain} #{Key}|, out: f.path)
      Process.wait spawn(*%W|plutil -convert json #{f.path}|)
      JSON.load(File.read(f.path))
   end
end

if __FILE__ == $PROGRAM_NAME then
   puts '#!/bin/sh'
   puts

   `defaults find #{Key}`.each_line.collect {|line|
      line.match(/^Found [^']*'(?<domain>.*)': {$/) {|m| m[:domain] }
   }.select {|x| x }.each do |dom|
      read_NSUserKeyEquivalents(dom).each do |k, v|
         puts Shellwords.join(%W|defaults write #{dom} #{Key} -dict-add #{k} #{v}|)
      end
   end
end
