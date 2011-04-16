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
    module Hook

      @@listener_classes = []
      @@listeners = nil
      @@hook_modifiers = {}

      class << self
        # Adds a listener class.
        # Automatically called when a class inherits from K3cms::ThemeSupport::HookListener.
        def add_listener(klass)
          raise "Hooks must include Singleton module." unless klass.included_modules.include?(Singleton)
          @@listener_classes << klass
          clear_listeners_instances
        end

        # Returns all the listerners instances.
        def listeners
          @@listeners ||= @@listener_classes.uniq.collect {|listener| listener.instance}
        end

        # Clears all the listeners.
        def clear_listeners
          @@listener_classes = []
          clear_listeners_instances
        end

        # Clears all the listeners instances.
        def clear_listeners_instances
          @@listeners = nil
          @@hook_modifiers = {}
        end

        # Take the content captured with a hook helper and modify with each HookModifier
        def render_hook(hook_name, content, context, locals = {})
          modifiers_for_hook(hook_name).inject(content) { |result, modifier| modifier.apply_to(result, context, locals) }
        end

        # All the HookModifier instances that are associated with this hook_name in extension load order and order they were defined
        def modifiers_for_hook(hook_name)
          @@hook_modifiers[hook_name] ||= listeners.map {|l| l.modifiers_for_hook(hook_name)}.flatten
        end

      end

    end
  end
end


