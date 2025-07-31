class Task < ApplicationRecord
  after_create_commit { broadcast_create! }
  after_update_commit { broadcast_updates! }
  after_destroy_commit { broadcast_replace_to 'tasks', target: dom_id(self) }

  def broadcast_create!
    #broadcast_prepend_to "tasks", target: "tasksTable", partial: "tasks/loading"
    #sleep(0.1)
    broadcast_replace_to 'tasks', target: dom_id(self), locals: { event: self, transition_class: "in-out" }
  end

  def broadcast_updates!
    #broadcast_replace_to 'tasks', target: dom_id(self) , partial: "tasks/loading"
    #sleep(0.1)
    broadcast_replace_to 'tasks', target: dom_id(self), locals: { event: self, transition_class: "in-out" }
  end
end
