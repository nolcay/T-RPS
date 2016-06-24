require "socket"
require "twitter"
require "json"
auth = JSON.parse(File.read("trpsauth.json"))
twitclient = Twitter::REST::Client.new do |config|
  config.consumer_key    = auth["ck"]
  config.consumer_secret = auth["cs"]
  config.access_token        = auth["at"]
  config.access_token_secret = auth["as"]
end
Thread.abort_on_exception = true
serv = TCPServer.new("0.0.0.0", 39975)
loop do
  Thread.start(serv.accept) do |player|
    wl = ""
    loop {
      player.puts "Connected to the server"
      player.puts "First to two wins."
      score = [0, 0]
      loop do
        player.puts "Rock, Paper, Scissors! (r p s)"
        a = ""
        loop {
          a = player.gets.chop
          puts "yay got input " + a
          break if ["r", "p", "s"].include?(a)
        }
        puts "yay passed loop"
        b = %w/r p s/.sample
        puts "yay sampled"
        if a == b
          puts "yay evaluated if"
          player.puts a + " - " + b + " Tie. " + score.join(" - ")
        elsif (a == "r" and b == "s") or (a == "s" and b == "p") or (a == "p" and b == "r")
          puts "yay evaluated if"
          score[0] += 1
          player.puts a + " - " + b + " You win! " + score.join(" - ")
        else
          puts "yay evaluated if"
          score[1] += 1
          player.puts a + " - " + b + " You lose. " + score.join(" - ")
        end
        puts "yay passed if"
        break if score.include?(2)
      end
      if score[0] == 2
        player.puts "You won the match " + score.join(" - ") + "!"
        wl = "won"
      else
        player.puts "You lost the match " + score.join(" - ") + ". Better luck next time!"
        wl = "lost"
      end
      player.puts "Would you like your results to be posted on twitter?"
      twitres = false
      loop {
        twitres = player.gets.chop
        break if ["y", "n"].include?(twitres)
      }
      if twitres
        twitusr = ""
        loop {
          player.puts "What is your Twitter username? (@username)"
          twitusr = player.gets.chop
          twitusr[0] == "@" ? break : twitusr = "@" + twitusr; break
        }
        twitclient.update "[T-RPS] Player " + twitusr + " " + wl + " " + score.join(" to ")
      end
      player.puts "Would you like to play again? (y/n)"
      re = ""
      loop {
        re = player.gets.chop
        break if ["y", "n"].include?(re)
      }
      break if re == "n"
    }
    player.puts "Thank you for your time!"
    player.close
  end
end