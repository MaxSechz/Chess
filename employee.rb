class Employee

  attr_reader :name, :title, :salary, :boss

  def initialize(name, title, salary, boss = nil)
    @name, @title, @salary, @boss = name, title, salary, boss
  end

  def bonus(multiplier)
    @salary * multiplier
  end

end

class Manager < Employee

  attr_reader :team # might override

  def initialize(name, title, salary, boss = nil, team)
    super(name, title, salary, boss)

    @team = team
  end

  def bonus(multiplier)

    total_salaries = team.inject(0) do |total, employee|
      team_salaries = 0
      if employee.is_a? Manager
        team_salaries = employee.team.inject do |subtotal, subemployee|
          subtotal += subemployee.bonus(1)
        end
      end

      total += (employee.salary + team_salaries)
    end

    total_salaries * multiplier
  end

end
