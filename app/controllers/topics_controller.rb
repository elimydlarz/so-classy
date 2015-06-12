class TopicsController < ApplicationController

  before_filter :correct_user, only: [ :edit, :update ]

  def new
  end

  def index
    order_by = :popularity
    direction = :descending

    if sort_params.permitted?
      order_by = sort_params[:order_by].to_sym if ['name', 'popularity'].include? sort_params[:order_by]
      direction = sort_params[:direction].to_sym if ['ascending', 'descending'].include? sort_params[:direction]
    end

    @topics = Topic.all.sort_by(&order_by)

    if(direction == :descending)
      @topics = @topics.reverse
    end
  end

  def create
    @topic = Topic.new(topic_params)
    @topic.owner = current_user
    @topic.save!

    redirect_to @topic
  rescue ActiveRecord::RecordInvalid
    existing_topic = Topic.find_by_name(topic_params['name'])
    redirect_to(existing_topic) unless existing_topic.nil?
  end

  def show
    @topic = Topic.find(params[:id])
  end

  def edit
    @topic = Topic.find(params[:id])
  end

  def update
    @topic = Topic.find(params[:id])

    @topic.update_attributes(topic_params)

    @topic.save!

    flash[:success] = 'Topic updated'

    redirect_to topic_path(@topic)
  rescue ActiveRecord::RecordInvalid
    flash[:error] = "Validation failed!"

    redirect_to edit_topic_path(@topic)
  end

  def destroy
    topic = Topic.find(params[:id])
    if current_user == topic.owner
      topic.destroy!
      flash[:success] = 'Topic deleted'
      redirect_to :topics
    else
      flash[:error] = 'Only the creator of a topic can delete it'
      redirect_to topic
    end
  end

  def add_teacher
    topic = Topic.find(params[:id])
    topic.teachers << current_user
    topic.save!
    redirect_to(topic)
  rescue ActiveRecord::RecordInvalid
    render nothing: true, status: 409
  end

  def remove_teacher
    topic = Topic.find(params[:id])
    topic.teachers.delete(current_user)
    topic.save!
    redirect_to(topic)
  end

  def add_student
    topic = Topic.find(params[:id])
    topic.students << current_user
    topic.save!
    redirect_to(topic)
  rescue ActiveRecord::RecordInvalid
    render nothing: true, status: 409
  end

  def remove_student
    topic = Topic.find(params[:id])
    topic.students.delete(current_user)
    topic.save!
    redirect_to(topic)
  end

private

  def topic_params
    params.require(:topic).permit(:name, :description)
  end

  def sort_params
    params.permit(:order_by, :direction)
  end

  def correct_user
    @topic = Topic.find(params[:id])
    if not current_user?(@topic.owner)
      flash[:error] = 'Can not update the selected topic'
      redirect_to :root
    end
  end

end
