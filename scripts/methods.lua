-- guess why is all of this here? hehe

function new_table(n, value)
	local t = {}
	for i = 1, n do t[#t + 1] = value or 0 end
	return t
end

function sum(table_a, table_b)
	assert(#table_a == #table_b)
	local t = {}
	for i = 1, #table_a do
		t[i] = table_a[i] + table_b[i]
	end
end

function transpose(matrix)
	-- transpose a matrix
	local m = {}
	for i = 1, #matrix[1] do m[i] = {} end
	for i = 1, #matrix do
		for j = 1, #matrix[1] do
			m[j][i] = matrix[i][j]
		end
	end
	return m
end

function vector_multiplication(vector_a, vector_b)
	assert(#vector_a == #vector_b)
	local result = 0
	for i = 1, #vector_a do
		result = result + vector_a[i] * vector_b[i]
	end
	return result
end

function exp(vector)
	local v = {}
	for i = 1, #vector do
		v[i] = 2.71828182 ^ vector[i]
	end
	return v
end

function max(vector)
	local m, f = 0, true
	for i = 1, #vector do
		if (m < vector[i] or f) then
			m = vector[i]
			f = false
		end
	end
	return m
end

function min(vector)
	local m, f = 0, true
	for i = 1, #vector do
		if (m > vector[i] or f) then
			m = vector[i]
			f = false
		end
	end
	return m
end

require'math'
function log(vector)
	local v = {}
	for i = 1, #vector do
		v[i] = math.log(vector[i])
	end
	return v
end

local function matrixout(m)
	for k,v in pairs(m) do
		local s = ""
		for l,b in pairs(v) do
			s = s..tostring(b).." "
		end
		print(s)
	end
end

local function MultiplyMatrices(matrix1, matrix2)
	assert(#matrix1[1] == #matrix2)
	local rmatrix = {}
	local n = #matrix2[1]
	local m = #matrix2
	for i = 1, #matrix1 do
		rmatrix[i] = {}
		for j = 1, n do
			local s = 0
			for m1 = 1, m do
				s = s + matrix1[i][m1] * matrix2[m1][j]
			end
			rmatrix[i][j] = s
		end
	end
	return rmatrix
end

local function LoadCheckPoints(str)

end

local function SaveCheckpoint(tbl)

end

e = 2.7182818
local function sigmoid(x)
	return 1 / (1 + e ^ (-x))
end

local function CreateLayer(n_inputs, n_neurons)
	local Layer = {}
	Layer.weights = {}
	for i = 1, n_inputs do
		Layer.weights[i] = {}
		for j = 1, n_neurons do
			Layer.weights[i][j] = (math.random() - .5) * 20
		end
	end
	Layer.biases = {}
	for i = 1, n_neurons do
		Layer.biases[i] = 0
	end

	function Layer.forward(inputs)
		local output = MultiplyMatrices(inputs, (Layer.weights))
		for i = 1, #inputs do
			for j = 1, #Layer.biases do
				output[i][j] = output[i][j] + Layer.biases[j]
			end
		end--]]
		Layer.output = output
	end

	function Layer.sigmoid()
		for i = 1, #Layer.output do
			for j = 1, #Layer.output[i] do
				Layer.output[i][j] = sigmoid(Layer.output[i][j])
			end
		end
	end

	function Layer.custom_logit()
		for i = 1, #Layer.output do
			for j = 1, #Layer.output[i] do
				Layer.output[i][j] = custom_logit(Layer.output[i][j])
			end
		end
	end

	return Layer
end

inputs = {{1,2,0,.4},}
--	  {12,.1,1,-12}} 

layer = CreateLayer(4,2) -- dis is ma playground, ai like it
layer2 = CreateLayer(2,3)
layer3 = CreateLayer(3,4)
layer4 = CreateLayer(4,5)

layer.forward(inputs)
layer.sigmoid()

matrixout(layer.output)


layer2.forward(layer.output)
layer2.custom_logit()

matrixout(layer2.output)


layer3.forward(layer2.output)
layer3.sigmoid()

matrixout(layer3.output)


layer4.forward(layer3.output)
layer4.sigmoid()

matrixout(layer4.output)