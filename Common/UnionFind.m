%{
  file:	UnionFind.m
	SYNOPSIS:
		The universe U is a set of "items".  Initially U is empty.
		Each item will be assigned an arbitrary but
		unique index (or pointer).  Our data structure will be
		mainly manipulating the indices, not the actual items!
	
		The set of items are partitioned into equivalent classes.
		Each equivalence class has a unique item called its
		"representative".
		
		The 3 methods are:
		   x = ADD(X)	-- adds an item X to U, returns index of X.
		   		   X is in its own equivalence class.
				   We write X=ITEM(x) in this case.
		   UNION(x,y)	-- merges the equivalence class of x and y
		   y = FIND(x)  -- returns the representative index y
		   		   of the equivalence class of x.
	
		
		* Thus, x and y are equivalent iff FIND(x)=FIND(y).
		* We assume each item X is a number, but we can
		    generalize to arbitrary objects if desired.
		* We can represent the universe by an array ITEM such
		    that ITEM(x) returns the item with index x.
	
	THEORY:
		We use the "Compressed Tree" data structure to
		implement Union Find.  Each item in this structure
		has a parent pointer.   We use pointers to either point
		to another item, or to itself.  The only cycles formed
		by these pointers are when a pointer points to itself -- 
		such items represent the root of a tree in the forest.
	
		Thus, we have an array called PARENT that has the
		the same size as the ITEM array.  Normally, PARENT(x)
		is the index of the parent of x (all indices are positive
		numbers).  However, when x "points to itself", we
		let the value of PARENT(x) be negative of the size
		of the equivalence class of x.   I.e.,
		
		   PARENT(x) =	{ index of the parent of ITEM(x),
				{ 		if PARENT(x)>0,
				{ -size of the equivalence class of ITEM(x)
				{		if PARENT(x)<0
	
		E.g., if PARENT(x)=-5, then the equivalvence class of ITEM(x)
		has 5 elements.
	
	E.g., after ADD'ing the items 111, 333, 555, 777, the ITEM array
	becomes
		ITEM = [111, 333, 555, 777].
	Moreover, the index of 111, 333, 555 and 777 are just 1, 2, 3 and 4.
	The PARENT array in then
		PARENT = [-1, -1, -1, -1].
	
	Suppose, we perform UNION(1,2).   Then the PARENT array may become 
		PARENT = [2, -2, -1, -1]
	(it could also become PARENT = [-2, 1, -1, -1]).
	
	If we perform UNION(2,4), then we may now get
		PARENT = [2, -3, -1, 2]  or [2, 4, -1, -3].
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	Robotics Class, Spring 2017
	Chee Yap with TA's Rohit Muthyala and Naman 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%}

classdef UnionFind < handle
     properties
       ITEM = [];
       PARENT = [];
       index = 0;
     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj= UnionFind()
		% Constructor
            obj.index =1;
        end

        function show(obj)	
		% SHOW() displays the ITEM and PARENT arrays.
            display(obj.ITEM);
            display(obj.PARENT);
        end

        function idx = add(obj, item)
		% ADD(item) will add item to the universe and return its index.
            idx = obj.index;
            obj.ITEM = [obj.ITEM item];
            obj.PARENT(idx) = -1;
            obj.index =  idx + 1;
        end

        function root = find(obj, x)
		% FIND(x) returns the index of the representative of the 
		%   equivalence class of ITEM(x).
			root = x.unionFindIdx;
            %disp(root);
            while (obj.PARENT(root) > 0)
                root = obj.PARENT(root);
            end

            % PATH COMPRESSION HEURISTIC
            z = x.unionFindIdx;
            while z ~= root
            	parentIdx = obj.PARENT(z);
            	obj.PARENT(z) = root;
            	z = parentIdx;
            end
        end

        function yy = union(obj, x, y)
		% UNION(x,y) makes either FIND(x) point to FIND(y) or vice-versa.
            xx = find(obj,x);
            yy = find(obj,y);
            if xx ~= yy
            	link(obj,xx,yy);
            end
         end

        function link(obj,xx,yy)
		% LINK(xx,yy) is helper for union;
		%   it simply makes xx points to yy
			if -xx >= -yy
				obj.PARENT(xx) = obj.PARENT(xx) + obj.PARENT(yy);
				obj.PARENT(yy) = xx;
			else
            	obj.PARENT(yy) = obj.PARENT(xx) + obj.PARENT(yy);
            	obj.PARENT(xx) = yy;
            end
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods(Static)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function test()			
		% TEST() is static method to exercise the Union Find data structure.
	    a = UnionFind;
	    ADD(a,10); ADD(a,11); ADD(a,12); ADD(a,13); ADD(a,14);
	    disp('-->> ADD(a,10); ADD(a,11); ADD(a,12); ADD(a,13); ADD(a,14);');
	    
	    union(a,1,2); union(a,3,2); union(a,4,1); union(a,5,3);
	    disp('-->> union(a,1,2); union(a,3,2); union(a,4,1); union(a,5,3);');

	    x = find(3);
	    disp(['-->> find(3) -->', num2str(x)]);

	    ADD(a,21); ADD(a,22); ADD(a,23);
	    disp('-->> ADD(a,21); ADD(a,22); ADD(a,23); ');

	    union(a,6,7);
	    disp('-->> union(a,6,7);');
		
	    % the next 2 lines can be replaced by show().
	    disp('-->> ITEM :');  disp(a.ITEM);
	    disp('-->> PARENT :'); disp(a.PARENT);
	   end
	end
end