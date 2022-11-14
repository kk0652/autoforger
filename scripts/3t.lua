local function eqcheck(this, other) return this[1] == other[1] and this[2] == other[2] end

local function Matrix(data)

	local self = data or {{}}

	function self.shape(m)
		return ''..#m..' '..#m[1]
	--	setmetatable(sh,{__tostring=function(s) return ''..s[1]..' '..s[2] end, __eq=eqcheck})
	end

	function self.transposed(this)
		local m = Matrix()
		local s, d = #this, #this[1]
		for i = 1, (#this[1]) do m[i] = {} end
		for i = 1, s do
			for j = 1, d do
				m[j][i] = this[i][j]
			end
		end
		return m
	end

	function self.multiply(this, other)
		if (#this[1]) == (#other) then
			-- matrix multiplication
			local result = Matrix()
			local d2, d1 = #other[1], #other
			for i = 1, #this do
				result[i] = {}
				for j = 1, d2 do
					local s = 0
					for m1 = 1, d1 do
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
		local d = #m[1]
		for i = 1, #m do
			r[i] = {}
			for j = 1, d do
				r[i][j] = fn(m[i][j])
			end
		end
		return r
	end

	local function multiply_scalar(this, other)
		local r = Matrix()
		local ts1, ts2 = #this, #this[1]
		if type(other) == 'number' then
			for i = 1, ts1 do
				r[i] = {}
				for j = 1, ts2 do
					r[i][j] = this[i][j] * other
				end
			end
		else
			local os1, os2 = #other, #other[1]
			if ts2 == os2 and os1 == 1 then
				for i = 1, ts1 do
					r[i] = {}
					for j = 1, ts2 do
						r[i][j] = this[i][j] * other[1][j]
					end
				end
			elseif (ts1 == os1 and ts2 == os2) then
				for i = 1, ts1 do
					r[i] = {}
					for j = 1, ts2 do
						r[i][j] = this[i][j] * other[i][j]
					end
				end
			else
				error('Scalar multiplication was unsuccessful!\nMatrix 1:\n'..tostring(this)..'\nInstance 2:\n'..tostring(other or 'nil'))
			end
		end
		return r
	end

	local function addition(this, other)
		local ts1, ts2, os1, os2 = #this, #this[1], #other, #other[1]		
		if (ts1 == os1 and ts2 == os2) then
			local r = Matrix()
			for i = 1, ts1 do
				r[i] = {}
				for j = 1, ts2 do
					r[i][j] = this[i][j] + other[i][j]
				end
			end
			return r
		elseif ts1 == os1 and os2 == 1 then
			local r = Matrix()
			for i = 1, ts1 do
				r[i] = {}
				for j = 1, ts2 do
					r[i][j] = this[i][j] + other[i][1]
				end
			end
			return r
		elseif ts1 == os1 and ts2 == 1 then
			local r = Matrix()
			for i = 1, ts1 do
				r[i] = {}
				for j = 1, ts2 do
					r[i][j] = other[i][j] + this[i][1]
				end
			end
			return r
		else
			error("Addition was unsuccessful!\nMatrix 1 :\n"..tostring(this)..'\nMatrix 2:\n'..tostring(other or 'nil'))
		end
	end

	local function minus(m)
		local r = Matrix()
		local d = #m[1]
		for i = 1, #m do
			r[i] = {}
			for j = 1, d do
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
		local d = #m[1]
		for i = 1, #m do
			for j = 1, d do
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

local function relu(x)
	return x > 0.5 and x or 0
end

local function relu_derivative(x)
	return x > 0.5 and 1 or 0
end

local function mse_prime(y_true, y_expected)
	return (y_true - y_expected):apply(function(x) return 2 * x / (y_true:size()) end)
end

local function mse(y_true, y_expected)
	local temp = (y_true - y_expected):apply(function(x) return 2 * x^2 end)
	local r = 0
	for i = 1, #y_true do
		for j = 1, #y_true[1] do
			r = r + temp[i][j]
		end
	end
	return r / (y_true:size())
end

local function RandomMatrix(dim1, dim2, t)
	local result = Matrix()
	for i = 1, dim1 do
		result[i] = {}
		for j = 1, dim2 do
			result[i][j] = t or math.random()
		end
	end
	return result
end

learning_rate = .1

local function Layer_Dense(input_size, output_size, loaded)
	local Layer = {}
	Layer.weights = loaded or RandomMatrix(output_size, input_size)
	Layer.biases = loaded or RandomMatrix(output_size, 1, 0.01)
	function Layer:forward(input)
		Layer.input = input
		t = (Layer.weights:multiply(Layer.input)) + Layer.biases
		return t
	end
	function Layer:backward(output_gradient)
		local weights_gradient = output_gradient:multiply(Layer.input:transposed())
		Layer.weights = Layer.weights - weights_gradient * learning_rate
		Layer.biases = Layer.biases - output_gradient * learning_rate
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

local function clip(inst)
	if type(inst[1]) == 'table' then
		for i = 1, #inst do
			for j = 1, #inst[1] do
				inst[i][j] = math.max(math.min(inst[i][j], .999999999), .00000001)
			end
		end
	else
		for i = 1, #inst do
			inst[i] = math.max(math.min(inst[i], .999999999), .00000001)
		end
	end
	return inst
end

local function custom_logit(x)
	local r = 0.15 * math.log(x / (1 - x)) + 0.5
	return r
end

local function what_even_is_this(x)
	return math.max(math.min(4 * (x^2 - x) + 1, .999999999), .00000001)
end

local function linear(x)
	return x / 10
end
local function linear_deriv(x)
	return .1
end

local function tanh(x)
	return (e^x - e^(-x)) / (e^x + e^(-x))
end

local function tanh_deriv(x)
	return 1 - (tanh(x))^2
end

network = {
	Layer_Dense(1,8),
	Layer_Activation(tanh, tanh_deriv),
	Layer_Dense(8,8),
	Layer_Activation(tanh, tanh_deriv),
	Layer_Dense(8,8),
	Layer_Activation(tanh, tanh_deriv),
	Layer_Dense(8,1),
	Layer_Activation(tanh, tanh_deriv),
}
network.metadata = #network
local function my_magic_function(x)
	return math.sin(3.14 * x)
end

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
		input[i] = {a,b}
		output[i] = {xor(a,b)}
	end
	return Matrix(input), Matrix(output)
end

function generate_my_data(n)
	local input = {}
	local output = {}
	for i = 1, n do
		t = math.random()
		input[i] = {t}
		output[i] = {my_magic_function(t)}
	end
	return Matrix(input), Matrix(output)
end


-- [[


--]]
-- [[

fn_default = tanh
fn_deriv_default = tanh_deriv

function custom_serialize(tbl, shape)
	local str = shape or ''
	for i = 1, #tbl do
		if type(tbl[i]) == 'table' then
			str = str..custom_serialize(tbl[i])
		else
			str = str..' '..tbl[i]
		end
	end
	return str
end
function custom_readtable(str)
	local tbl = Matrix({{}})
	local dim1 = tonumber(str:sub(1,1))
	local dim2 = tonumber(str:sub(3,3))
	local cur = ''
	local dim1_count = 1
	local dim2_count = 1
	for i = 5, #str do
		char = str:sub(i,i)
		if char ~= ' ' then
			cur = cur..char
		else
			tbl[dim1_count][dim2_count] = tonumber(cur)
			dim2_count = dim2_count + 1
			if dim2_count > dim2 then
				dim2_count = 1
				dim1_count = dim1_count + 1

				tbl[dim1_count] = {}
				if dim1_count > dim1 then
					error('Something is wrong with the data I was trying to read!')
				end
			end
			cur = ''
		end
	end
	tbl[dim1_count][dim2_count] = tonumber(cur)
	return tbl
end
function SaveCheckpoint(network, filename)
	local file = io.open(filename, 'w')
	file:write(#network..'\n')
	for i = 1, #network, 2 do
		file:write(custom_serialize(network[i].weights, (network[i].weights:shape()))..'\n')
		file:write(custom_serialize(network[i].biases, (network[i].biases:shape()))..'\n')
	end
	file:close()
end

local function lines_of_file(filename)
	local lines = {}
	local file = io.open(filename)
	for line in file:lines() do
		lines[#lines + 1] = line
	end
	file:close()
	return lines
end

function LoadCheckpoint(filename)
	local load_network = {}
	local lines = lines_of_file(filename)
	local n = tonumber(lines[1]) / 2
	for i = 1, n do
		load_network[(i - 1) * 2 + 1] = Layer_Dense(1,1, true)
		load_network[(i - 1) * 2 + 1].weights = custom_readtable(lines[i * 2])
		load_network[(i - 1) * 2 + 1].biases = custom_readtable(lines[i * 2 + 1])
		load_network[i * 2] = Layer_Activation(fn_default, fn_deriv_default)
	end
	return load_network
end

local function lrate(err)
	if err < 1e-6 then return 1
	elseif err < 1e-5 then return 0.5
	elseif err < 1e-4 then return 0.1
	else return 0.01
	end
end

function Train(network, times, batch_size, data_fn)
	local err, grad
	for time = 1, times do
		err = 0
		X, Y = data_fn(batch_size)
		X = X:transposed()
		for layer = 1, #network do
			X = network[layer]:forward(X)
		end
		err = err + mse(X, Y:transposed())
		grad = mse_prime(X, Y:transposed())
		for layer = #network, 1, -1 do
			--print(grad)
			grad = network[layer]:backward(grad)
		end
		if time % 1000 == 0 then
			print("Current error:", err / #Y)
		end
		learning_rate = lrate(err)
	end
	return network
end

function Forward(network, X)
	X = X:transposed()
	for layer = 1, #network do
		X = network[layer]:forward(X)
	end
	return X
end

while true do
	a = loadstring(io.read())
	a()
end--]]