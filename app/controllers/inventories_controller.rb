class InventoriesController < ApplicationController
  before_action :set_inventory, only: %i[show destroy]
  before_action :authorize_user, only: [:destroy]

  def index
    @inventories = current_user.inventories.includes(:inventory_foods)
  end

  def show; end

  def new
    @inventory = Inventory.new
  end

  def create
    @inventory = current_user.inventories.build(inventory_params)

    respond_to do |format|
      if @inventory.save
        format.html { redirect_to @inventory, notice: 'Recipe created successfully!' }
        format.json { render :show, status: :created, location: @recipe }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end

  end

  def destroy
    @inventory.inventory_foods.destroy_all

    if !@inventory.inventory_foods.any? && @inventory.destroy
      flash[:notice] = 'Inventory was successfully destroyed.'
    else
      flash[:alert] = 'Inventory is linked to a food and cannot deleted!'
    end
      redirect_to inventories_url
  end

  def shopping_list
    @inventory = Inventory.find(params[:id])
    @recipe = Recipe.find(params[:recipe_id])

    recipe_foods = @recipe.recipe_foods
    inventory_foods = @inventory.inventory_foods

    @missing_foods = []
    @foods = []

    recipe_foods.each do |recipe_food|
      food = recipe_food.food
      inventory_food = inventory_foods.find_by(food_id: food.id)

      next unless inventory_food.nil? || inventory_food.quantity < recipe_food.quantity

      missing_quantity = inventory_food.nil? ? recipe_food.quantity : recipe_food.quantity - inventory_food.quantity

      @missing_foods << {
        name: food.name,
        missing_quantity:,
        cost: missing_quantity * food.price
      }
      @foods << food
    end

    @total_cost = @missing_foods.reduce(0) { |total, food| total + food[:cost] }
  end

  private

  def set_inventory
    @inventory = Inventory.includes(:inventory_foods).find(params[:id])
  end

  def authorize_user
    return if current_user == @inventory.user

    redirect_to inventories_path,
                notice: 'Not authorized to perform this action'
  end

  def inventory_params
    params.require(:inventory).permit(:name, :description)
  end
end
