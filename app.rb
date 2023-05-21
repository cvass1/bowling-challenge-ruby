class Application
  def initialize(io)
    @io = io
    @score_table = []
    @total_frames = 10
    @max_rolls = 2
    @last_roll = {
      frame: 0,
      roll: 0,
      pins: 0,
      frame_score: 0,
      notes: ''
    }
    @second_last_roll = @last_roll

  end

  def run
    run_game
    print_result
  end

  def run_game
    frame = 1
    while frame <= @total_frames do
      play_frame(frame)
      frame +=1
    end
    return @score_table.sum {|roll| roll[:frame_score] }
  end

  private

  def play_frame(frame)
    roll = 1
    while roll <= @max_rolls do
      if @last_roll[:roll] == 1 && @last_roll[:notes] == 'strike'
        pins = 0
      else
        @io.puts "Frame #{frame}, roll #{roll}: Enter number of knocked down pins:"
        pins = @io.gets.chomp.to_i
      end
      add_score(frame,roll,pins)
      if frame == 10 && @last_roll[:notes] == 'spare'
        @max_rolls = 3
      elsif frame == 10 && @last_roll[:notes] == 'strike'
        @max_rolls = 4
      end
      roll += 1
    end
  end

  def add_score(frame,roll,pins)    
    if roll == 1 && pins == 10
      note = 'strike'
    elsif roll == 2 && @last_roll[:pins] == 10
      note = 'strike'
    elsif roll == 2 && (pins + @last_roll[:pins] == 10)
      note = 'spare'
    end

    if roll == 2
      frame_score = pins + @last_roll[:pins]
    else
      frame_score = 0
    end

    if @score_table.length > 1 
      if @score_table[-2][:notes] == 'strike' && @score_table[-2][:frame_score] >= 10
        @score_table[-2][:frame_score] += pins
      end

      if @score_table.length > 3
        if @score_table[-1][:notes] == 'strike' && @score_table[-1][:frame_score] >= 10 && @score_table[-3][:notes] == 'strike'
          @score_table[-3][:frame_score] += pins
        end
      end

    end

    if @score_table.length > 0 
      if (@score_table[-1][:notes] == 'strike' || @score_table[-1][:notes] == 'spare') && @score_table[-1][:frame_score] >= 10
        @score_table[-1][:frame_score] += pins
      end
    end


    @last_roll = {
      frame: frame,
      roll: roll,
      pins: pins,
      frame_score: frame_score,
      notes: note
    }
    
    @score_table << @last_roll
  end

  def print_result
    @score_table.each{ |entry|
      @io.puts entry
    }
  end

end


if __FILE__ == $0
  app = Application.new(
    Kernel
  )
  app.run
end