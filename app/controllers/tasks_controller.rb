class TasksController < ApplicationController
  before_action :require_auth!

  def create
    task_service = TaskService.new(Task)
    result = task_service.create_task(create_params.merge(user_id: current_user_id))

    if result[:errors].present?
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    else
      render json: result, status: :created
    end
  end

  def show
    task_service = TaskService.new(Task)
    task = task_service.find_task(params[:id], current_user_id)

    if task.nil?
      render json: { error: "Task not found" }, status: :not_found
    else
      render json: task, status: :ok
    end
  end

  def index
    page = params.fetch(:page, 1).to_i
    limit = params.fetch(:limit, 20).to_i
  
    task_service = TaskService.new(Task)
    result = task_service.find_all(current_user_id, page, limit)

    render json: result, status: :ok
  end

  def update
    task_service = TaskService.new(Task)
    task = task_service.update_task(params[:id], current_user_id, update_params)
    return render json: { error: "Task not found" }, status: :not_found if task.nil?
    
    if task[:errors].present?
      render json: { errors: task[:errors] }, status: :unprocessable_entity
    else
      render json: task, status: :ok
    end
  end

  def delete
    task_service = TaskService.new(Task)
    task = task_service.delete_task(params[:id], current_user_id)

    if task.nil?
      render json: { error: "Task not found" }, status: :not_found
    else
      render json: { message: "Task deleted successfully" }, status: :ok
    end
  end

  private

  def create_params
    params.permit(:title, :description, :due_date, :priority)
  end

  private

  def update_params
    params.permit(:title, :description, :due_date, :priority, :completed)
  end
end
