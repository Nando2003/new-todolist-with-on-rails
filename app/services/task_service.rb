class TaskService
  def initialize(task_model)
    @task_model = task_model
  end

  def create_task(params)
    task = @task_model.new(params)

    return task if task.save
    { 
      errors: task.errors.to_hash(true)
    }
  end

  def find_task(id, user_id)
    @task_model.find_by(id: id, user_id: user_id)
  end

  def find_all(user_id, page, limit)
    tasks = @task_model.where(user_id: user_id).limit(limit).offset((page - 1) * limit)
    total_count = @task_model.where(user_id: user_id).count
    total_pages = (total_count.to_f / limit).ceil

    {
      data: tasks,
      pagination: {
        current_page: page,
        per_page: limit,
        total_pages: total_pages,
        total_count: total_count
      }
    }
  end

  def update_task(id, user_id, params)
    task = find_task(id, user_id)
    return nil if task.nil?

    if task.update(params)
      task
    else
      { 
        errors: task.errors.to_hash(true)
      }
    end
  end

  def delete_task(id, user_id)
    task = find_task(id, user_id)
    return nil if task.nil?

    task.destroy
    task
  end
end