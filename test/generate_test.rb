require "test_helper"
require "json"

class GenerateTest < Minitest::Spec
  # UNIT TEST {Generate::Representer}
  it "works with PRO's JSON format" do
    # from ../pro-rails/test/fixtures/bpmn2/moderation.xml-exported.json
    moderation_json = File.read("test/fixtures/v1/moderation.json")

    collaboration = Trailblazer::Workflow::Generate::Representer::Collaboration.new(OpenStruct.new).from_json(moderation_json)

    assert_equal collaboration.id, 1

    lifecycle_lane = collaboration.lanes.find { |lane| lane.id == "article moderation" }

    assert_equal lifecycle_lane.id, "article moderation"

    # assert_equal lifecycle_lane.type "lane"
    assert_equal lifecycle_lane.elements.size, 39

    create = lifecycle_lane.elements[12]
    assert_equal create.id, "Activity_0wwfenp"
    assert_equal create.label, "Create"
    assert_equal create.type, :task
    assert_equal create.links.size, 2
    assert_equal create.links[0].target_id, "throw-after-Activity_0wwfenp"
    assert_equal create.links[0].semantic, :success
    assert_equal create.links[1].target_id, "Event_0odjl3c"
    assert_equal create.links[1].semantic, :failure
    assert_equal create.data, {}

    suspend = lifecycle_lane.elements[32]
    assert_equal suspend.id, "suspend-Gateway_1wzosup"
    assert_equal suspend.type, :suspend
    assert_equal suspend.links.size, 0
    assert_equal suspend.data["resumes"], ["catch-before-Activity_0wr78cv", "catch-before-Activity_0q9p56e"]
  end

  it do
    moderation_json = File.read("test/fixtures/v1/moderation.json")

    signal, (ctx, _) = Trailblazer::Workflow::Generate.invoke([{json_document: moderation_json}, {}])

    lanes = ctx[:intermediates]

    # pp lanes
    # TODO: test ui lane
    # puts lanes["article moderation"].pretty_inspect
    assert_equal lanes["article moderation"].pretty_inspect, %(#<struct Trailblazer::Activity::Schema::Intermediate
 wiring=
  {#<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Event_0odjl3c",
    data={:type=>:throw_event, :label=>"invalid!"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-gw-to-catch-before-Activity_0wwfenp">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Event_0txlti3",
    data={:type=>:throw_event, :label=>"invalid!"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-Gateway_0fnbg3r">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Event_1p8873y",
    data={:type=>:terminus, :label=>"success"}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Event_1oucl4z",
    data={:type=>:throw_event, :label=>"invalid!"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-Gateway_01p7uj7">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Activity_0q9p56e",
    data={:type=>:task, :label=>"Update"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="throw-after-Activity_0q9p56e">,
     #<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:failure,
      target="Event_0txlti3">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Activity_0wr78cv",
    data={:type=>:task, :label=>"Notify approver"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="throw-after-Activity_0wr78cv">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Activity_1qrkaz0",
    data={:type=>:task, :label=>"Approve"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="throw-after-Activity_1qrkaz0">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Activity_1bjelgv",
    data={:type=>:task, :label=>"Publish"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="throw-after-Activity_1bjelgv">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Activity_1hgscu3",
    data={:type=>:task, :label=>"Archive"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="throw-after-Activity_1hgscu3">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Activity_0cc4us9",
    data={:type=>:task, :label=>"Delete"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="throw-after-Activity_0cc4us9">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Activity_18qv6ob",
    data={:type=>:task, :label=>"Revise"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="throw-after-Activity_18qv6ob">,
     #<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:failure,
      target="Event_1oucl4z">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Activity_0d9yewp",
    data={:type=>:task, :label=>"Reject"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="throw-after-Activity_0d9yewp">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Activity_0wwfenp",
    data={:type=>:task, :label=>"Create"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="throw-after-Activity_0wwfenp">,
     #<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:failure,
      target="Event_0odjl3c">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="catch-before-Activity_0wwfenp",
    data={"start_task"=>true, :type=>:catch_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Activity_0wwfenp">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="throw-after-Activity_0wwfenp",
    data={:type=>:throw_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-Gateway_0fnbg3r">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="catch-before-Activity_0q9p56e",
    data={:type=>:catch_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Activity_0q9p56e">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="throw-after-Activity_0q9p56e",
    data={:type=>:throw_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-Gateway_1wzosup">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="catch-before-Activity_0wr78cv",
    data={:type=>:catch_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Activity_0wr78cv">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="throw-after-Activity_0wr78cv",
    data={:type=>:throw_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-Gateway_0y3f8tz">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="catch-before-Activity_1qrkaz0",
    data={:type=>:catch_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Activity_1qrkaz0">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="throw-after-Activity_1qrkaz0",
    data={:type=>:throw_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-Gateway_1hp2ssj">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="catch-before-Activity_1bjelgv",
    data={:type=>:catch_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Activity_1bjelgv">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="throw-after-Activity_1bjelgv",
    data={:type=>:throw_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-gw-to-catch-before-Activity_1hgscu3">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="catch-before-Activity_1hgscu3",
    data={:type=>:catch_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Activity_1hgscu3">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="throw-after-Activity_1hgscu3",
    data={:type=>:throw_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Event_1p8873y">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="catch-before-Activity_0cc4us9",
    data={:type=>:catch_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Activity_0cc4us9">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="throw-after-Activity_0cc4us9",
    data={:type=>:throw_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Event_1p8873y">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="catch-before-Activity_18qv6ob",
    data={:type=>:catch_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Activity_18qv6ob">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="throw-after-Activity_18qv6ob",
    data={:type=>:throw_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-Gateway_1kl7pnm">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="catch-before-Activity_0d9yewp",
    data={:type=>:catch_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Activity_0d9yewp">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="throw-after-Activity_0d9yewp",
    data={:type=>:throw_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-Gateway_01p7uj7">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-Gateway_0fnbg3r",
    data=
     {"resumes"=>
       ["catch-before-Activity_0q9p56e", "catch-before-Activity_0wr78cv"],
      :type=>:suspend}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-Gateway_1wzosup",
    data=
     {"resumes"=>
       ["catch-before-Activity_0wr78cv", "catch-before-Activity_0q9p56e"],
      :type=>:suspend}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-Gateway_0y3f8tz",
    data=
     {"resumes"=>
       ["catch-before-Activity_0d9yewp", "catch-before-Activity_1qrkaz0"],
      :type=>:suspend}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-Gateway_1hp2ssj",
    data=
     {"resumes"=>
       ["catch-before-Activity_1bjelgv",
        "catch-before-Activity_0cc4us9",
        "catch-before-Activity_0q9p56e"],
      :type=>:suspend}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-Gateway_01p7uj7",
    data={"resumes"=>["catch-before-Activity_18qv6ob"], :type=>:suspend}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-Gateway_1kl7pnm",
    data=
     {"resumes"=>
       ["catch-before-Activity_18qv6ob", "catch-before-Activity_0wr78cv"],
      :type=>:suspend}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-gw-to-catch-before-Activity_0wwfenp",
    data={"resumes"=>["catch-before-Activity_0wwfenp"], :type=>:suspend}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-gw-to-catch-before-Activity_1hgscu3",
    data={"resumes"=>["catch-before-Activity_1hgscu3"], :type=>:suspend}>=>[]},
 stop_task_ids=
  {"Event_1p8873y"=>:Event_1p8873y,
   "suspend-Gateway_0fnbg3r"=>:suspend,
   "suspend-Gateway_1wzosup"=>:suspend,
   "suspend-Gateway_0y3f8tz"=>:suspend,
   "suspend-Gateway_1hp2ssj"=>:suspend,
   "suspend-Gateway_01p7uj7"=>:suspend,
   "suspend-Gateway_1kl7pnm"=>:suspend,
   "suspend-gw-to-catch-before-Activity_0wwfenp"=>:suspend,
   "suspend-gw-to-catch-before-Activity_1hgscu3"=>:suspend},
 start_task_id="catch-before-Activity_0wwfenp">
)


    assert_equal lanes["<ui> author workflow"].pretty_inspect, %(#<struct Trailblazer::Activity::Schema::Intermediate
 wiring=
  {#<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Event_1npw1tg",
    data={:type=>:catch_event, :label=>"accepted?"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-Gateway_1sq41iq">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Event_1bz3ivj",
    data={:type=>:catch_event, :label=>"valid?"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-Gateway_1g3fhu2">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Event_1wly6jj",
    data={:type=>:catch_event, :label=>"invalid?"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Activity_19m1lnz">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Event_1vb197y",
    data={:type=>:catch_event, :label=>"rejected?"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-gw-to-catch-before-Activity_0zsock2">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Activity_1165bw9",
    data={:type=>:task, :label=>"Update form"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-Gateway_0nxerxv">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Activity_1dt5di5",
    data={:type=>:task, :label=>"Notify approver"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="throw-after-Activity_1dt5di5">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Activity_0bsjggk",
    data={:type=>:task, :label=>"Publish"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="throw-after-Activity_0bsjggk">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Activity_15nnysv",
    data={:type=>:task, :label=>"Delete"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="throw-after-Activity_15nnysv">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Activity_0ha7224",
    data={:type=>:task, :label=>"Delete? form"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-Gateway_100g9dn">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Activity_1uhozy1",
    data={:type=>:task, :label=>"Cancel"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-Gateway_1sq41iq">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Activity_1wiumzv",
    data={:type=>:task, :label=>"Revise"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="throw-after-Activity_1wiumzv">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Activity_0zsock2",
    data={:type=>:task, :label=>"Revise form"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-Gateway_1xs96ik">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Activity_0j78uzd",
    data={:type=>:task, :label=>"Update"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="throw-after-Activity_0j78uzd">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Event_1vf88fn",
    data={:type=>:catch_event, :label=>"valid?"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-Gateway_1g3fhu2">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Event_1nt0djb",
    data={:type=>:catch_event, :label=>"invalid?"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Activity_00kfo8w">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Activity_00kfo8w",
    data={:type=>:task, :label=>"Update form with errors"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-Gateway_0nxerxv">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Activity_19m1lnz",
    data={:type=>:task, :label=>"Revise form with errors"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-Gateway_1xs96ik">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Activity_0fy41qq",
    data={:type=>:task, :label=>"Archive"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="throw-after-Activity_0fy41qq">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Event_1vrfxsv",
    data={:type=>:catch_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Event_0h6yhq6">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Event_0j1jua6",
    data={:type=>:catch_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Event_0h6yhq6">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Event_19ha0ea",
    data={:type=>:catch_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-gw-to-catch-before-Activity_0fy41qq">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Event_0h6yhq6",
    data={:type=>:terminus, :label=>"success"}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Event_0co8ygx",
    data={:type=>:catch_event, :label=>"invalid?"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Activity_08p0cun">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Event_0km79t5",
    data={:type=>:catch_event, :label=>"valid?"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-Gateway_0kknfje">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Activity_1psp91r",
    data={:type=>:task, :label=>"Create"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="throw-after-Activity_1psp91r">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Activity_08p0cun",
    data={:type=>:task, :label=>"Create form with errors"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-Gateway_14h0q7a">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="catch-before-Activity_1dt5di5",
    data={:type=>:catch_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Activity_1dt5di5">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="throw-after-Activity_1dt5di5",
    data={:type=>:throw_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-Gateway_063k28q">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="catch-before-Activity_0bsjggk",
    data={:type=>:catch_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Activity_0bsjggk">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="throw-after-Activity_0bsjggk",
    data={:type=>:throw_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-gw-to-Event_19ha0ea">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="catch-before-Activity_15nnysv",
    data={:type=>:catch_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Activity_15nnysv">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="throw-after-Activity_15nnysv",
    data={:type=>:throw_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-gw-to-Event_1vrfxsv">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="catch-before-Activity_1wiumzv",
    data={:type=>:catch_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Activity_1wiumzv">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="throw-after-Activity_1wiumzv",
    data={:type=>:throw_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-Gateway_1sch8el">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="catch-before-Activity_0j78uzd",
    data={:type=>:catch_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Activity_0j78uzd">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="throw-after-Activity_0j78uzd",
    data={:type=>:throw_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-Gateway_1runwh1">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="catch-before-Activity_0fy41qq",
    data={:type=>:catch_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Activity_0fy41qq">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="throw-after-Activity_0fy41qq",
    data={:type=>:throw_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-gw-to-Event_0j1jua6">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="catch-before-Activity_1psp91r",
    data={:type=>:catch_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Activity_1psp91r">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="throw-after-Activity_1psp91r",
    data={:type=>:throw_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-Gateway_1d05yki">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="catch-before-Activity_1165bw9",
    data={:type=>:catch_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Activity_1165bw9">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="catch-before-Activity_0ha7224",
    data={:type=>:catch_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Activity_0ha7224">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="catch-before-Activity_1uhozy1",
    data={:type=>:catch_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Activity_1uhozy1">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="catch-before-Activity_0zsock2",
    data={:type=>:catch_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Activity_0zsock2">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="Activity_0wc2mcq",
    data={:type=>:task, :label=>"Create form"}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="suspend-Gateway_14h0q7a">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="catch-before-Activity_0wc2mcq",
    data={"start_task"=>true, :type=>:catch_event}>=>
    [#<struct Trailblazer::Activity::Schema::Intermediate::Out
      semantic=:success,
      target="Activity_0wc2mcq">],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-Gateway_01cn7zv",
    data={"resumes"=>["catch-before-Activity_1165bw9"], :type=>:suspend}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-Gateway_0nxerxv",
    data={"resumes"=>["catch-before-Activity_0j78uzd"], :type=>:suspend}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-Gateway_063k28q",
    data={"resumes"=>["Event_1npw1tg", "Event_1vb197y"], :type=>:suspend}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-Gateway_1sq41iq",
    data=
     {"resumes"=>
       ["catch-before-Activity_1165bw9",
        "catch-before-Activity_0ha7224",
        "catch-before-Activity_0bsjggk"],
      :type=>:suspend}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-Gateway_1sch8el",
    data={"resumes"=>["Event_1bz3ivj", "Event_1wly6jj"], :type=>:suspend}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-Gateway_1xs96ik",
    data={"resumes"=>["catch-before-Activity_1wiumzv"], :type=>:suspend}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-Gateway_100g9dn",
    data=
     {"resumes"=>
       ["catch-before-Activity_15nnysv", "catch-before-Activity_1uhozy1"],
      :type=>:suspend}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-Gateway_1runwh1",
    data={"resumes"=>["Event_1vf88fn", "Event_1nt0djb"], :type=>:suspend}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-Gateway_1g3fhu2",
    data=
     {"resumes"=>
       ["catch-before-Activity_1165bw9", "catch-before-Activity_1dt5di5"],
      :type=>:suspend}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-Gateway_14h0q7a",
    data={"resumes"=>["catch-before-Activity_1psp91r"], :type=>:suspend}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-Gateway_1d05yki",
    data={"resumes"=>["Event_0km79t5", "Event_0co8ygx"], :type=>:suspend}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-Gateway_0kknfje",
    data=
     {"resumes"=>
       ["catch-before-Activity_1165bw9", "catch-before-Activity_1dt5di5"],
      :type=>:suspend}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-gw-to-Event_1vrfxsv",
    data={"resumes"=>["Event_1vrfxsv"], :type=>:suspend}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-gw-to-Event_0j1jua6",
    data={"resumes"=>["Event_0j1jua6"], :type=>:suspend}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-gw-to-Event_19ha0ea",
    data={"resumes"=>["Event_19ha0ea"], :type=>:suspend}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-gw-to-catch-before-Activity_0fy41qq",
    data={"resumes"=>["catch-before-Activity_0fy41qq"], :type=>:suspend}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-gw-to-catch-before-Activity_0zsock2",
    data={"resumes"=>["catch-before-Activity_0zsock2"], :type=>:suspend}>=>[],
   #<struct Trailblazer::Activity::Schema::Intermediate::TaskRef
    id="suspend-gw-to-catch-before-Activity_0wc2mcq",
    data={"resumes"=>["catch-before-Activity_0wc2mcq"], :type=>:suspend}>=>[]},
 stop_task_ids=
  {"Event_0h6yhq6"=>:Event_0h6yhq6,
   "suspend-Gateway_01cn7zv"=>:suspend,
   "suspend-Gateway_0nxerxv"=>:suspend,
   "suspend-Gateway_063k28q"=>:suspend,
   "suspend-Gateway_1sq41iq"=>:suspend,
   "suspend-Gateway_1sch8el"=>:suspend,
   "suspend-Gateway_1xs96ik"=>:suspend,
   "suspend-Gateway_100g9dn"=>:suspend,
   "suspend-Gateway_1runwh1"=>:suspend,
   "suspend-Gateway_1g3fhu2"=>:suspend,
   "suspend-Gateway_14h0q7a"=>:suspend,
   "suspend-Gateway_1d05yki"=>:suspend,
   "suspend-Gateway_0kknfje"=>:suspend,
   "suspend-gw-to-Event_1vrfxsv"=>:suspend,
   "suspend-gw-to-Event_0j1jua6"=>:suspend,
   "suspend-gw-to-Event_19ha0ea"=>:suspend,
   "suspend-gw-to-catch-before-Activity_0fy41qq"=>:suspend,
   "suspend-gw-to-catch-before-Activity_0zsock2"=>:suspend,
   "suspend-gw-to-catch-before-Activity_0wc2mcq"=>:suspend},
 start_task_id="catch-before-Activity_0wc2mcq">
)
  end
end
