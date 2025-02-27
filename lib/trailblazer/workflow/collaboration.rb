module Trailblazer
  module Workflow
    class Collaboration
      class Schema
        def initialize(lanes:, message_flow:, options:{})
          @lanes                  = lanes
          @message_flow           = message_flow
          # @initial_lane_positions = Synchronous.initial_lane_positions(lanes.values)
          # @options = options # FIXME: test me!!!
        end

        # attr_reader :initial_lane_positions
        # attr_reader :message_flow
        # attr_reader :lanes # @private

        def to_h
          {
            message_flow: @message_flow,
            # initial_lane_positions: @initial_lane_positions, # DISCUSS: do we really nee
            lanes: @lanes,
          }
        end
      end # Schema

      class Position < Struct.new(:activity, :task)
        def to_h
          {
            activity: activity,
            task:     task
          }
        end
      end

      # DISCUSS: rename to State or something better matching?
      # Keeps the collaboration lane positions after running, it's a "state"
      class Configuration < Struct.new(:lane_positions, :signal, :ctx, :flow_options, :last_lane, keyword_init: true) # DISCUSS: should we keep ctx/flow_options?
      end

      module Synchronous # DISCUSS: (file) location.
        module_function

        # @private
        # Returns a fake Suspend event that maintains the actual start events in its {:resume_events}.
        def initial_lane_positions(lanes)
          lanes.collect do |activity|
            catch_id = Trailblazer::Activity::Introspect.Nodes(activity, task: activity.to_h[:circuit].to_h[:start_task]).id # DISCUSS: store IDs or the actual catch event in {:resumes}?

            [
              activity,
              {"resumes" => [catch_id], semantic: [:suspend, "from initial_lane_positions"]} # We deliberately have *one* position per lane, we're Synchronous. # TODO: use a real {Event::Suspend} here.
            ]
          end
          .to_h
        end

        # Triggers the {start_task} event and runs the entire collaboration until message is sent and
        # the throwing activity stops in a suspend or End terminus.
        # @private
        def advance(collaboration, (ctx, flow), circuit_options, lane_positions:, start_position:, message_flow:)
          signal = nil

          # start_task, activity,
          loop do
            start_position = start_position.to_h

            Synchronous.validate_targeted_position(lane_positions, **start_position)

            circuit_options = circuit_options.merge(start_task: start_position[:task])

            # signal, (ctx, flow) = Activity::TaskWrap.invoke(start_position[:activity], [ctx, flow], **circuit_options)
            signal, (ctx, flow) = Trailblazer::Developer.wtf?(start_position[:activity], [ctx, flow], **circuit_options)

            # now we have :throw, or not
            # @returns Event::Throw::Queued

            # now, "log" the collaboration's state.
            lane_positions = advance_position(lane_positions, start_position[:activity], signal)

            break unless flow[:throw].any?
            # break if (@options[:skip_message_from] || []).include?(flow[:throw][-1][0]) # FIXME: untested!

            debug_points_to = start_position[:activity].to_h[:circuit].to_h[:map][start_position[:task]]
            Trailblazer::Activity::Introspect.Nodes(start_position[:activity], task: start_position[:task]).data
            puts "
>>>>>>>>> FROM \033[1msuspend ---> #{debug_points_to}\033[0m"

            flow, start_position = receiver_task(flow, message_flow)
            # every time we "deliver" a message, we should check if it's allowed (meaning the receiving activity is actually in the targeted catch event)
          end

          return Configuration.new(
            lane_positions: lane_positions,
            signal:         signal,
            last_lane:      start_position[:activity], # DISCUSS: do we need that, or should we infer that using {signal}?
          ),
          [ctx, flow]
        end

        # @private
        # every time we "deliver" a message, we should check if it's allowed (meaning the receiving activity is actually in the targeted catch event)
        # {:activity} and {:task} are the targeted position.
        def validate_targeted_position(lane_positions, activity:, task:)
          # the *actual* receiver position, where we're currently.
          actual_receiver_position = lane_positions[activity] # receiver should always be in a suspend task/event gateway.

#           puts "######### #{} | #{task}
# >>>>>>>>> #{actual_receiver_position}"
#           puts

          reachable_catch_events = actual_receiver_position.to_h["resumes"]
            .collect { |catch_id| Trailblazer::Activity::Introspect.Nodes(activity, id: catch_id).task }

          # if possible_catch_event_ids =
          return true if reachable_catch_events.include?(task)
          # end

          raise "Message can't be passed to #{task} because #{activity} is not in appropriate position"
        end

        # @private
        # @param signal Workflow::Event::Suspend
        def advance_position(lane_positions, activity, suspend_event)
          lane_positions.merge(activity => suspend_event)
        end





        # @private
        def receiver_task(flow, message_flow)
          next_throw, *remaining = flow[:throw]

          throwing_event  = next_throw[0] # DISCUSS: why array in Synchronous?
          flow = flow.merge(throw: remaining)

          return flow, receiver_position_for(message_flow, throwing_event)
        end

        # @private
        def receiver_position_for(message_flow, throwing_event)
          receiver_activity, catch_task = message_flow.fetch(throwing_event)

          Position.new(receiver_activity, catch_task)
        end
      end # Synchronous
    end
  end
end
