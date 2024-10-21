classdef pythonOrdinaryKriging < matlab.System
    % untitled Add summary here
    %
    % This template includes the minimum set of functions required
    % to define a System object.

    % Public, tunable properties
    properties
        
    end

    % Pre-computed constants or internal states
    properties (Access = private)
        variogram_model,
        x,
        y,
        z,
        min_x, max_x,
        min_y, max_y,
    end

    methods (Access = protected)
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants
            obj.variogram_model = "exponential";
        end

        function zstar = stepImpl(obj, x, y, z)
            % Implement algorithm. Calculate y as a function of input u and
            % internal states.
            obj.x.append(x)
            obj.y.append(y)
            obj.z.append(z)
            % obj.x{end+1} = x;
            % obj.y{end+1} = y;
            % obj.z{end+1} = z;

            if x > obj.max_x
                obj.max_x = x;
            elseif x < obj.min_x
                obj.min_x = x;
            end

            if y > obj.max_y
                obj.max_y = y;
            elseif y < obj.min_y
                obj.min_y = y;
            end

            OK = py.pykrige.OrdinaryKriging(obj.x, obj.y, obj.z, obj.variogram_model);
            
            % x_range = obj.min_x:0.5:obj.max_x;
            % y_range = obj.min_y:0.5:obj.max_y;

            x_range = -100:5:100;
            y_range = -100:5:100;

            res = OK.execute("grid", py.list(x_range), py.list(y_range));

            heatmap(double(res{1}), "GridVisible", "off", "CellLabelColor", "none")

            zstar = double(res{1});
        end

        function resetImpl(obj)
            obj.x = py.list({0});
            obj.y = py.list({0});
            obj.z = py.list({0});
            obj.min_x = 10000;
            obj.max_x = -10000;
            obj.min_y = 10000;
            obj.max_y = -10000;
            % Initialize / reset internal properties
        end

        function out = getOutputSizeImpl(obj)
            % Return size for each output port
            % out = [length(obj.min_x:0.5:obj.max_x) length(obj.min_y:0.5:obj.max_y)];
            out = [41 41];

            % Example: inherit size from first input port
            % out = propagatedInputSize(obj,1);
        end

        function out = getOutputDataTypeImpl(obj)
            % Return data type for each output port
            out = "double";

            % Example: inherit data type from first input port
            % out = propagatedInputDataType(obj,1);
        end

        function out = isOutputComplexImpl(obj)
            % Return true for each output port with complex data
            out = false;

            % Example: inherit complexity from first input port
            % out = propagatedInputComplexity(obj,1);
        end

        function out = isOutputFixedSizeImpl(obj)
            % Return true for each output port with fixed size
            out = false;

            % Example: inherit fixed-size status from first input port
            % out = propagatedInputFixedSize(obj,1);
        end
    end
end
