local function eqcheck(this, other) return this[1] == other[1] and this[2] == other[2] end

local function Matrix(data)

	local self = data or {{}}

	function self.shape(m)
		local sh = {#m,#m[1]}
		setmetatable(sh,{__tostring=function(s) return '{'..s[1]..','..s[2]..'}' end, __eq=eqcheck})
		return sh
	end

	function self.transposed(this)
		local m = Matrix()
		for i = 1, (this:shape())[2] do m[i] = {} end
		for i = 1, (this:shape())[1] do
			for j = 1, (this:shape())[2] do
				m[j][i] = this[i][j]
			end
		end
		return m
	end

	function self.multiply(this, other)
		if (this:shape())[2] == (other:shape())[1] then
			-- matrix multiplication
			local result = Matrix()
			for i = 1, this:shape()[1] do
				result[i] = {}
				for j = 1, (other:shape())[2] do
					local s = 0
					for m1 = 1, (other:shape())[1] do
						s = s + this[i][m1] * other[m1][j]
					end
					result[i][j] = s
				end
			end
			return result
		else
			error('Multiplaction was unsuccessful!\nMatrix 1:\n'..tostring(this)..'\nMatrix 2:\n'..tostring(other or 'nil'))
		end
	end

	function self.apply(m, fn)
		local r = Matrix()
		for i = 1, m:shape()[1] do
			r[i] = {}
			for j = 1, m:shape()[2] do
				r[i][j] = fn(m[i][j])
			end
		end
		return r
	end

	local function multiply_scalar(this, other)
		local r = Matrix()
		if type(other) == 'number' then
			for i = 1, this:shape()[1] do
				r[i] = {}
				for j = 1, this:shape()[2] do
					r[i][j] = this[i][j] * other
				end
			end
		elseif this:shape()[2] == other:shape()[2] and other:shape()[1] == 1 then
			for i = 1, this:shape()[1] do
				r[i] = {}
				for j = 1, this:shape()[2] do
					r[i][j] = this[i][j] * other[1][j]
				end
			end
		elseif (this:shape() == other:shape()) then
			for i = 1, this:shape()[1] do
				r[i] = {}
				for j = 1, this:shape()[2] do
					r[i][j] = this[i][j] * other[i][j]
				end
			end
		else
			error('Scalar multiplication was unsuccessful!\nMatrix 1:\n'..tostring(this)..'\nInstance 2:\n'..tostring(other or 'nil'))
		end
		return r
	end

	local function addition(this, other)
		local compare_result = this:shape() == other:shape()
		if not compare_result then print(compare_result, this, other) end
		if compare_result then
			local r = Matrix()
			for i = 1, this:shape()[1] do
				r[i] = {}
				for j = 1, this:shape()[2] do
					r[i][j] = this[i][j] + other[i][j]
				end
			end
			return r
		else
			error("Addition was unsuccessful!\nMatrix 1 ("..tostring(this:shape()).."):\n"..tostring(this)..'\nMatrix 2 ('..tostring(other:shape())..'):\n'..tostring(other or 'nil')..'\nShape equality: '..tostring(this:shape() == other:shape()))
		end
	end

	local function minus(m)
		local r = Matrix()
		for i = 1, m:shape()[1] do
			r[i] = {}
			for j = 1, m:shape()[2] do
				r[i][j] = -m[i][j]
			end
		end
		return r
	end

	function self.size(m)
		return #m * #m[1]
	end

	local function tostring(m)
		local str = ''
		for i = 1, (m:shape())[1] do
			for j = 1, (m:shape())[2] do
				str = str..str.format('%.5f  ', m[i][j])
			end
			str = str..'\n'
		end
		return str
	end

	setmetatable(self, {
	__tostring = tostring,
	__mul = multiply_scalar,
	__add = addition,
	__unm = minus,
	__sub = function(this, other) return this + (-other) end
	})

	return self
end

e = 2.7182818
local function sigmoid(x)
	return 1 / (1 + e ^ (-x))
end

local function sigmoid_derivative(x)
	local s = sigmoid(x)
	return s * (1 - s)
end


local function mse_prime(y_true, y_expected)
	return (y_true - y_expected):apply(function(x) return 2 * x / (y_true:size()) end)
end

local function mse(y_true, y_expected)
	local temp = (y_true - y_expected):apply(function(x) return x^2 end)
	local r = 0
	for i = 1, y_true:shape()[1] do
		for j = 1, y_true:shape()[2] do
			r = r + temp[i][j]
		end
	end
	return r / (y_true:size())
end

local function RandomMatrix(dim1, dim2)
	local result = Matrix()
	for i = 1, dim1 do
		result[i] = {}
		for j = 1, dim2 do
			result[i][j] = math.random()
		end
	end
	return result
end

local function Layer_Dense(input_size, output_size)
	local Layer = {}
	Layer.learning_rate = 0.02
	Layer.weights = RandomMatrix(output_size, input_size)
	Layer.biases = RandomMatrix(output_size, 1)
	function Layer:forward(input)
		Layer.input = input
		t = (Layer.weights:multiply(Layer.input)) + Layer.biases
		return t
	end
	function Layer:backward(output_gradient)
		local weights_gradient = output_gradient:multiply(Layer.input:transposed())
		Layer.weights = Layer.weights - weights_gradient * Layer.learning_rate
		Layer.biases = Layer.biases - output_gradient * Layer.learning_rate
		local t = (Layer.weights:transposed()):multiply(output_gradient)
		return t
	end
	return Layer
end

local function Layer_Activation(activation_fn, activation_prime_fn)
	local Layer = {}
	Layer.activation = activation_fn
	Layer.activation_prime = activation_prime_fn
	function Layer:forward(input)
		Layer.input = input
		return (Layer.input:apply(Layer.activation))
	end
	function Layer:backward(output_gradient)
		local output = output_gradient * (Layer.input:apply(Layer.activation_prime))
		return output
	end
	return Layer
end

network = {
	Layer_Dense(2,4),
	Layer_Activation(sigmoid, sigmoid_derivative),
	Layer_Dense(4,1),
	Layer_Activation(sigmoid, sigmoid_derivative),
}

function xor(a,b)
	return ((a == 1 or b == 1) and not (a == 1 and b == 1)) and 1 or 0
end
local bits = {1,0}
local function generate_xor_data(n)
	local input = {}
	local output = {}
	local a, b
	for i = 1, n do
		a = bits[math.random(1,2)]
		b = bits[math.random(1,2)]
		input[i] = Matrix({{a,b}})
		output[i] = Matrix({{xor(a,b)}})
	end
	return input, output
end

input_data, output_data = generate_xor_data(150)


-- [[
print(network[1].biases)
for time = 1, 1000 do
	err = 0
	for data_index = 1, #input_data do
		output = input_data[data_index]:transposed()
		for layer = 1, #network do
			output = network[layer]:forward(output)
		end
		err = err + mse(output, output_data[data_index])
		grad = mse_prime(output, output_data[data_index])
		for layer = #network, 1, -1 do
			grad = network[layer]:backward(grad)
		end
	end
	if time % 100 == 0 then
		print("Current error:", err / #input_data)
	end
end

function getResult(a,b)
	local data = Matrix({{a,b}})
	for layer = 1, #network do
		data = network[layer]:forward(data:transposed())
	end
	return data
end

--]]
-- [[

while true do
	a = loadstring(io.read())
	a()
end--]]
