require "lirb/version"

module Lirb

  class Number 
    def initialize(token)
      @value = token.to_i
    end

    def eval
      @value
    end
  end
  
  class Symbol 
    def initialize(token, env)
      @env = env
      @token = token
    end
    
    def eval
      @env[@token]
    end
  end
  
  class Expression
  end
  
  class Application
    def initialize
      @expressions = []
    end
    
    def add(expression)
      @expressions.push(expression)
    end

    def eval
      func = @expressions[0].eval
      func.call(*@expressions[1..-1].map { |x| x.eval})
    end
  end

  class IfElseExpression
    def initialize
    end

    def add(expression)
      if @condition.nil?
        @condition = expression
      elsif @if_expression.nil?
        @if_expression = expression
      elsif @else_expression.nil?
        @else_expression = expression
      else
        raise "Too many expressions for if-else expression!"
      end
    end

    def eval
      if @condition.eval
        return @if_expression.eval
      elsif !@else_expression.nil?
        return @else_expression.eval
      else
        return nil
      end
    end
  end

  class Assignment
    def initialize(var, env)
      @env = env
      @var = var
    end

    def add(expr)
      @expr = expr
      @env[@var] = expr.eval
    end

    def eval
      return @expr.eval
    end
  end

  class List
    def initialize(values = [])
      @values = values
    end

    def add(expr)
      @values.push(expr)
    end

    def eval
      return @values.map {|x| x.eval }
    end

    def concat(list)
      return List.new(@this.values + list)
    end
  end

  class Function
    def initialize(name, env)
      @name = name
      @global_env = env
      @local_env = {}
      @args = []
      @body = []
      env[@name] = this
    end

    def add_arg(var)
      @args.push(var)
    end

    def add(expr)
      @body.push(expr)
    end 
  end

  
  class Parser
    def tokenize(program)
      return program
               .gsub('(', ' ( ')
               .gsub(')', ' ) ')
               .gsub('[', ' [ ')
               .gsub(']', ' ] ')
               .split
    end
    
    def parse(tokens)
      puts "tokens #{tokens}"
      if tokens.length == 0
        raise "Unexpected EOF!"
      end
      
      token = tokens.shift 
      
      case token
      when '('
        case tokens[0]
        when "if"
          expr = IfElseExpression.new
          tokens.shift
        when "def"
          tokens.shift # pop off 'def'
          var = tokens.shift
          expr = Assignment.new(var, @env)
        when "defun"
          tokens.shift # pop off 'defun'
          var = tokens.shift
          fun = Function.new(var, env)
          if tokens[0] != "["
            raise "Syntax error. No argument list after (defun <name>)" 
          else
            tokens.shift # pop off [
          end
          while tokens[0] != "]"
            arg = tokens.shift
            fun.add_arg(arg)
          end
        else
          expr = Application.new
        end
        while tokens[0] != ')'
          expr.add(parse(tokens))
        end
        tokens.shift # pop off ')'
        return expr
      when ')'
        raise "Syntax error: unexpected )"
      when /^-?\d+/
        return Number.new(token)
      when "["
        list = List.new
        while tokens[0] != "]"
          list.add(parse(tokens))
        end
        tokens.shift # pop off "]"
        return list
      else
        return Symbol.new(token, @env)
      end
    end
    
    def ast
      return @forms
    end
    
    def run()
      result = nil
      if @forms.respond_to? :each
        @forms.each do | form |
          result = form.eval
        end
      else
        result = @forms.eval
      end
      
      return result
    end
    
    def initialize(program)
      @program = program
      @env = {"+" => ->(*args) { args.reduce(:+) },
              "-" => ->(*args) { args.reduce(:-) },
              ">" => ->(x,y) { x > y},
              "<" => ->(x,y) { x < y},
              "/" => ->(*args) { args.reduce(:/)},
              "conj" => ->(l, x) { l.concat([x]) }}
      @forms = []
      tokens = self.tokenize(@program)
      while !tokens.empty?
        form = self.parse(tokens)
        @forms.push(form)
      end
    end
  end
  
end
