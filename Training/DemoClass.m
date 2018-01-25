classdef DemoClass
   properties
      Value1,
      Value2,
      Value3
   end
   
   methods
       function obj = DemoClass(value1, value2, value3)
           if nargin < 3
               error('Constructor applies minimum 3 arguments');
           end
           obj.Value1 = value1;
           obj.Value2 = value2;
           obj.Value3 = value3;
       end
       function printValues(obj)
       % PRINTVALUES Print values of the properties of the current class
           message = ['Value 1: ', obj.Value1, '. Value 2: ', obj.Value2, '. Value 3: ', obj.Value3, '.'];
           disp(message);
       end
       function sumValues = calculateSumOfValues(obj)
          sumValues = obj.Value1 + obj.Value2 + obj.Value3;
       end
   end
end