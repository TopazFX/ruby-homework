def cut(cake)
  g = cake.split("\n").map(&:chars)
  raisins = g.flatten.count { |c| c != '.' }   # будь-який символ, крім '.', це родзинка
  area = g.size * g[0].size / raisins
  used = Array.new(g.size) { Array.new(g[0].size, false) }
  res = []
  solve(g, used, area, res)
  res
end

def solve(g, used, area, res)
  h = g.size
  w = g[0].size

  # перша вільна клітинка (зверху вниз, зліва направо)
  r, c = nil
  h.times { |i| w.times { |j| (r, c = i, j; break) if r.nil? && !used[i][j] } }
  return true if r.nil?

  # ширину пробуємо від найбільшої: так перший шматок буде найширшим
  area.downto(1) do |pw|
    next unless area % pw == 0
    ph = area / pw
    next if r + ph > h || c + pw > w

    rows = (r...r + ph).to_a
    cols = (c...c + pw).to_a
    next if rows.any? { |i| cols.any? { |j| used[i][j] } }
    next unless rows.sum { |i| cols.count { |j| g[i][j] != '.' } } == 1

    rows.each { |i| cols.each { |j| used[i][j] = true } }
    res << rows.map { |i| cols.map { |j| g[i][j] }.join }.join("\n")

    return true if solve(g, used, area, res)

    res.pop
    rows.each { |i| cols.each { |j| used[i][j] = false } }
  end
  false
end

cake = "........\n..o.....\n...o....\n........"
puts cut(cake).join("\n\n")