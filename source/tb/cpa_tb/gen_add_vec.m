
%% Generate random inputs to the opb and reference result

% call random function which will generate floating point numbers < 1

nsamples = 1000;
p = 16;

opa = zeros(nsamples,1);
opb = zeros(nsamples,1);

for i = 1:nsamples
	opa(i) = rand(1, 'double');
	opb(i) = rand(1, 'double');
end

opa = round(opa.*2^p);
opb = round(opb.*2^p);


result = opa+opb;

% result = dec2bin(typecast(result, 'uint16'));
% opa_x = dec2bin(typecast(opa, 'uint16'));
% opb_x = dec2bin(typecast(opb, 'uint16'));

result = dec2bin(result);
opa_x = dec2bin(opa);
opb_x = dec2bin(opb);


dlmwrite('opa.txt', opa_x, '');
dlmwrite('opb.txt', opb_x, '');
dlmwrite('result.txt', result, '');


write_finish = 1
