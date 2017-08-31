module Blocks
  # TODO: Make this render order customizable
  class BlockWithHooksRenderer < AbstractRenderer
    def render(*args, &default_definition)
      with_output_buffer do
        runtime_context = RuntimeContext.new(builder, *args, &default_definition)
        if !runtime_context.skip_completely
          adjacent_blocks_renderer.render(HookDefinition::BEFORE_ALL, runtime_context)
          nesting_blocks_renderer.render(HookDefinition::AROUND_ALL, runtime_context) do
            wrapper_renderer.render(runtime_context.wrap_all, runtime_context) do
              collection_renderer.render(runtime_context) do |runtime_context|
                wrapper_renderer.render(runtime_context.wrap_each, runtime_context) do
                  nesting_blocks_renderer.render(HookDefinition::AROUND, runtime_context) do
                    adjacent_blocks_renderer.render(HookDefinition::BEFORE, runtime_context)
                    if !runtime_context.skip_content
                      wrapper_renderer.render(runtime_context.wrap_with, runtime_context) do
                        nesting_blocks_renderer.render(HookDefinition::SURROUND, runtime_context) do
                          adjacent_blocks_renderer.render(HookDefinition::PREPEND, runtime_context)
                          block_renderer.render(runtime_context)
                          adjacent_blocks_renderer.render(HookDefinition::APPEND, runtime_context)
                        end
                      end
                    end
                    adjacent_blocks_renderer.render(HookDefinition::AFTER, runtime_context)
                  end
                end
              end
            end
          end
          adjacent_blocks_renderer.render(HookDefinition::AFTER_ALL, runtime_context)
        end
      end
    end
  end
end