require "test_helper"

class BoincRpcClientTest < ActiveSupport::TestCase
  setup { @client = BoincRpcClient.new("localhost") }

  test "cpu_display uses final elapsed time for finished tasks" do
    assert_equal "50.00%", @client.send(:cpu_display, 50.0, 100.0, 0.0, 0.0)
  end

  test "cpu_display uses current times for active tasks" do
    assert_equal "25.00%", @client.send(:cpu_display, 0.0, 0.0, 25.0, 100.0)
  end

  test "cpu_display handles zero elapsed time" do
    assert_equal "0.0", @client.send(:cpu_display, 50.0, 0.0, 0.0, 0.0)
  end

  test "state_display treats fraction_done as 0..1" do
    assert_equal "Running", @client.send(:state_display, 2, 0.5)
    assert_equal "Ready to start", @client.send(:state_display, 2, 0.0)
    assert_equal "Completed", @client.send(:state_display, 5, 1.0)
    assert_equal "Ready to report", @client.send(:state_display, 5, 0.0)
  end

  test "project_display handles hosts with and without dots" do
    assert_equal "World Community Grid", @client.send(:project_display, "https://www.worldcommunitygrid.org/")
    assert_equal "uwm", @client.send(:project_display, "https://einstein.phys.uwm.edu/")
    assert_equal "asteroidsathome", @client.send(:project_display, "http://asteroidsathome.net/boinc/")
    assert_equal "localhost", @client.send(:project_display, "http://localhost/")
    assert_equal "", @client.send(:project_display, "not a url")
  end
end
