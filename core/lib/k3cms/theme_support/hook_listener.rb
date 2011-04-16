#++
# Derived from code from Spree
# Copyright (c) 2007-2010, Rails Dog LLC and other contributors
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice,
#       this list of conditions and the following disclaimer in the documentation
#       and/or other materials provided with the distribution.
#     * Neither the name of the Rails Dog LLC nor the names of its
#       contributors may be used to endorse or promote products derived from this
#       software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#--

module K3cms
  module ThemeSupport

    # Listener class used for views hooks.
    class HookListener
      include Singleton

      attr_accessor :hook_modifiers

      def initialize
        @hook_modifiers = []
      end

      def modifiers_for_hook(hook_name)
        hook_modifiers.select{|hm| hm.hook_name == hook_name}
      end


      # Replace contents of hook_name using supplied render args or string returned from block
      def self.replace(hook_name, options = {}, &block)
        add_hook_modifier(hook_name, :replace, options, &block)
      end

      # Insert before existing contents of hook_name using supplied render args or string returned from block
      def self.insert_before(hook_name, options = {}, &block)
        add_hook_modifier(hook_name, :insert_before, options, &block)
      end

      # Insert after existing contents of hook_name using supplied render args or string returned from block
      def self.insert_after(hook_name, options = {}, &block)
        add_hook_modifier(hook_name, :insert_after, options, &block)
      end

      # Clear contents of hook_name
      def self.remove(hook_name)
        add_hook_modifier(hook_name, :replace)
      end


      private

        def self.add_hook_modifier(hook_name, action, options = {}, &block)
          if block
            renderer = lambda do |template, locals|
              template.controller.render_to_string(:inline => yield, :locals => locals)
            end
          else
            if options.empty?
              renderer = nil
            else
              renderer = lambda do |template, locals|
                render_args = [options]
                if options.is_a?(Hash)
                  options[:locals] = locals
                else
                  render_args << locals
                end
                template.render(*render_args)
              end
            end
          end
          instance.hook_modifiers << HookModifier.new(hook_name, action, renderer)
        end

    end

  end
end
