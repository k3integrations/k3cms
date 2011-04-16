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

    # A hook modifier is created for each usage of 'insert_before','replace' etc.
    # This stores how the original contents of the hook should be modified
    # and does the work of altering the hooks content appropriately
    class HookModifier
      attr_accessor :hook_name
      attr_accessor :action
      attr_accessor :renderer

      def initialize(hook_name, action, renderer = nil)
        @hook_name = hook_name
        @action = action
        @renderer = renderer
      end

      def apply_to(content, context, locals = {})
        return '' if renderer.nil?
        case action
        when :insert_before
          "#{renderer.call(context, locals)}#{content}".html_safe
        when :insert_after
          "#{content}#{renderer.call(context, locals)}".html_safe
        when :replace
          renderer.call(context, locals).to_s.html_safe
        else
          ''
        end
      end

    end

  end
end
