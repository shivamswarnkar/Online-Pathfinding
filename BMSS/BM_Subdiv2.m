%{
WARNING: it is VERY rough, and probably wrong!
num=conv([0 0.042],[-1/0.142 1]);
	Subdiv2
		-- derived from Subdiv1
        -- we compute adjancies for box2 objects

%}

classdef BM_Subdiv2 < Subdiv1 %& Geom2d
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        env;        % environment
        range;      % to determine if box is free not just potentially free
    end
    
    properties ( Access = private)
        %white = [1 1 1]
        %gray = [0.5 0.5 0.5]
        %red = [1 0 0]
        %yellow = [1 1 0]
        %green =[0 1 0]
        %colo = [[1 1 1];[0.5 0.5 0.5];[1 0 0]; [1 1 0]; [0 1 0]];
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Constructor for Subdiv2
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = BM_Subdiv2(giv_env, range)
            if (nargin < 1)
                giv_env = Environment('env0.txt');
                range = 1;
            elseif (nargin == 1)
                range = 1;
            end
            env = giv_env;
            bBox = env.bBox;
            x = (bBox.X(1)+ bBox.X(2)+ bBox.X(3)+ bBox.X(4))/4;
            y = (bBox.Y(1)+ bBox.Y(2)+ bBox.Y(3)+ bBox.Y(4))/4;
            %Assuming the convention that our bounding box starts from SW
            %corner and the remaining points are the other three corners in
            %clock-wise order
            w = abs(x - bBox.X(1));
            % Constructor for SubDiv
            obj = obj@Subdiv1(x,y,w);
            obj.rootBox.pNbr = [Box2.null Box2.null Box2.null Box2.null];
            obj.env = env;
            obj.setupRootFeatures();
            
            obj.range = range;

            %obj.unionF = UnionFind();
        end
        
        function setupRootFeatures(obj)
            obj.rootBox.features = [];
            for C = obj.env.polygons
                for i = 1:length(C{1}.X)
                    point = [C{1}.X(i), C{1}.Y(i)];
%                     disp(point)
                    if i == length(C{1}.X)
                        line = mapshape([C{1}.X(i) C{1}.X(1)], [C{1}.Y(i) C{1}.Y(1)], 'Geometry', 'line');
%                         disp(line)
                    else
                        line = mapshape([C{1}.X(i) C{1}.X(i+1)], [C{1}.Y(i) C{1}.Y(i+1)], 'Geometry', 'line');
%                         disp(line)
                    end
                    obj.rootBox.features{length(obj.rootBox.features) + 1} = point;
                    obj.rootBox.features{length(obj.rootBox.features) + 1} = line;
                end
            end
            disp('done with setup')
        end
        
        %	THIS IS A KEY METHOD:
        %		It is best to call sub-methods.
        %
        %         function child = split(obj)
        %		1. call Box2.split
        %		2. For each child:
        %			2.1 compute its features
        %			2.2 classify the child
        %			2.3 if FREE, add child to UnionFind structure
        %		3. For each child:
        %			If it is FREE, do UNION with all its neighbors
        %			%	NOTE that this is NOT done as step 2.4! Why?
        %         end
        
        % Split(box)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function split(obj, box)
            if(box.w <= obj.env.epsilon)
                return
            end
            box.split();
                        for i_dash = Idx.children()
                                i = Idx.quad(i_dash);
                                obj.updateFeatures(box.child(i));
                                obj.classify(box.child(i));
                                %box.child(i).showBox();
                                if (box.child(i).type == BoxType.FREE)
                                    %new_id = obj.unionF.add(box.child(i));
                                    %box.child(i).unionFindIdx = new_id;
                                end %if
                        end %for
            %obj.displaySubDiv();
            for i_dash = Idx.children()
                i = Idx.quad(i_dash);
                    box.child(i).pNbr = [Box2.null Box2.null Box2.null Box2.null];
                for j_dash = Idx.dirs()
                    k = Idx.quad(Idx.nbr(i_dash,j_dash));
                    j = Idx.dir(j_dash);
                    if(Idx.isSibling(i_dash,j_dash))
                        box.child(i).pNbr(j) = box.child(k);
                    else
                        if(box.pNbr(j).isLeaf)
                            box.child(i).pNbr(j) = box.pNbr(j);
                        else
                            box.child(i).pNbr(j) = box.pNbr(j).child(k);
                        end
                    end
                end
            end
            
%              for i_dash = Idx.children()
%                 i = Idx.quad(i_dash);
%                 child = box.child(i);
%                 if (child.type == BoxType.FREE)
%                     nbrs = obj.getNeighbours(child);
%                     for nbr = nbrs
%                         if ((nbr.w > 0) && nbr.type == BoxType.FREE)
%                             obj.unionF.union(nbr, child);
%                         end
%                     end
%                 end
%             end%for
        end %split
        
        function neighbour = getNeighbours(obj,box)
            dir = Idx.dirs();
            neighbour = [];
            neighbourPrn = [obj.getNbrDir(box,dir(1))...
                obj.getNbrDir(box,dir(2))...
                obj.getNbrDir(box,dir(3))...
                obj.getNbrDir(box,dir(4))];
            
            for i=1:length(neighbourPrn)
                if(obj.inRange(box, neighbourPrn(i)))
                    neighbour = [neighbour neighbourPrn(i)];
                end
            end
            
        end
        
        function flag = inRange(obj, b1, b2)
            sep = Geom2d.sep([b1.x, b1.y], [b2.x, b2.y]);
            %maxD = sqrt(((b1.w+b2.w)^2)+((b1.w-b2.w)^2));
            maxD = (b1.w + b2.w) * sqrt(2); %max possible distance in this case
            minD = b1.w + b2.w; %min possible distance in this case
            flag = (sep <= maxD) && (sep >= minD);
        end
        
        function nbrs = getNbrDir(obj,box,dir_dash)
            pN = box.pNbr(Idx.dir(dir_dash));
            if(pN.isLeaf)
                nbrs = [pN];
            else
                nbrs = obj.getLeavesDir(pN,dir_dash);
            end
        end
        
        function lvs = getLeavesDir(obj,box,dir_dash)
            if(box.isLeaf)
                lvs = [box];
            else
                dd = Idx.adj(dir_dash);
                lvs = [obj.getLeavesDir(box.child(Idx.quad(dd(1))),dir_dash)...
                    obj.getLeavesDir(box.child(Idx.quad(dd(2))),dir_dash)];
            end
        end
        
        function updateFeatures(obj,box)
            box.features = [];
            f = box.parent.features;
            for i = 1:length(f)
%                 disp('here');
%                 disp(f{i})
                %disp(Geom2d.sep([box.x, box.y], f{i}))
                if (Geom2d.sep([box.x, box.y], f{i}) < (obj.env.radius + box.w*sqrt(2)))
                    box.features{length(box.features)+1} = f{i};
                end
            end
        end
        
        
        function classify(obj,box)
            %disp(length(box.features));
            if(box.type == BoxType.FREE || box.type == BoxType.STUCK)
                return;
            end
            if(isempty(box.features))
                box.type = BoxType.PFREE; 
            elseif(box.w <= obj.env.epsilon)
                box.type = BoxType.STUCK;
            else
                box.type = BoxType.MIXED;
            end
            
            if(box.type == BoxType.PFREE && Geom2d.sep([box.x box.y], obj.env.currPos') <= obj.range - (obj.env.radius + box.w*sqrt(2)))
                box.type = BoxType.FREE;
            end
        end
        
        function plotLeaf(obj,box, type)
            if nargin < 2
                box = obj.rootBox;
            end
            if nargin < 3
                type = BoxType.UNKOWN;
            end
            %plot(box.shape().X,box.shape().Y,'b-');
            hold on;
            obj.plotLeaves(box,type);
            hold off;
        end
        
        function plotLeaves(obj, box, type)
            if(box.isLeaf && (box.type == type || type == BoxType.UNKOWN))
                fill(box.shape().X,box.shape().Y,obj.colo(box.type + 4,:));
                plot(box.shape().X,box.shape().Y,'b-');
            else
                for i = 1:length(box.child)
                    obj.plotLeaves(box.child(i),type);
                end
            end
            xlim([obj.rootBox.x - obj.rootBox.w, obj.rootBox.x + obj.rootBox.w]);
            ylim([obj.rootBox.y - obj.rootBox.w, obj.rootBox.y + obj.rootBox.w]);
        end
        
        function plotNbrs(obj, box, nbrsList, dir)
            
            if nargin < 3
                box = obj.rootBox;
            end
            if nargin < 4
                dir = 0;
            end
            hold on;
                                %disp(int32(box.type));
            fill(box.shape().X,box.shape().Y,obj.colo(box.type + 5,:));
            plot(box.shape().X,box.shape().Y,'b-');
            
            for i = 1:length(nbrsList)
                if(nbrsList(i) ~= Box2.null && (dir == 0))% dirs to be implemented
                    %Direction code incorrect needs fixing
                    fill(nbrsList(i).shape().X,nbrsList(i).shape().Y,obj.colo(nbrsList(i).type + 4,:));
                  
                    plot(nbrsList(i).shape().X,nbrsList(i).shape().Y,'b-');
                end
            end
            
            xlim([obj.rootBox.x - obj.rootBox.w, obj.rootBox.x + obj.rootBox.w]);
            ylim([obj.rootBox.y - obj.rootBox.w, obj.rootBox.y + obj.rootBox.w]);
            hold off;
        end
        
         function box = makeFree(obj, config)
            box = obj.findBox(config(1), config(2));
            while box.type ~= BoxType.FREE && box.w > obj.env.epsilon
                obj.split(box);
                box = obj.findBox(config(1), config(2));
            end
            if box.type ~= BoxType.FREE 
                box = [];
            end
         end
        
         function setPrev(obj,boxes, prevB)
             for box = boxes
%                  if(box.type == BoxType.FREE)
%                      obj.unionF.union(box, prevB);
%                  end
                 box.prev = prevB;
             end
         end
         
         function leaves = getRelvantLeaves(obj, box)
             leaves = Box2.empty();
            
             if box.isLeaf 
                 if box.type ~= BoxType.FREE && box.type ~= BoxType.STUCK
                     leaves = box;
                 end
                 return
             end
             for i=1:4
                 leaves = [leaves obj.getRelvantLeaves(box.child(i)) ];
             end
         end
         
         function distributeFeatures(obj, features)
             leaves = obj.getRelvantLeaves(obj.rootBox);
             for i = 1:length(features) 
                 for l = leaves
                      sep = Geom2d.sep([l.x l.y], features{i});
                      if sep <= (obj.env.radius + l.w*sqrt(2))
                          l.features{length(l.features) + 1} = features{i};
                          obj.classify(l);
                          
                      end
                 end
             end
         end
    end
    
    methods (Static = true)
        
         
      
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function test2()
            Subdiv2.test();
            return;
            
            s = Subdiv2('env0.txt');
            s.rootBox.split();
            
            
            s.displaySubDiv();
            s.env.showEnv(false);
        end
        function l = test()
            addpath ../Common;
            figure(1);
            clf(1);
            fname = 'env0.txt';
            s = BM_Subdiv2();
            box = s.makeFree(s.env.start);
            %box = s.makeFree(s.env.goal);
            %disp(box.type);
%             box.showBox()
            nbrs = s.getNeighbours(box);
            
%             for nbr = nbrs
%                 nbr.showBox();
%                 disp(nbr.type);
%             end
            s.split(nbrs(4));
            nbrs = box.pNbr;
%           unwlc = nbrs(4);
%             disp('here');
%             for nbr = nbrs
% %                 nbr.showBox();
%                 disp(nbr.type);
%             end
%             disp('------');
%             unwlc.showBox();
%             unwlcNbr = s.getNeighbours(unwlc);
%             for nbr = unwlcNbr
%                 nbr.showBox();
%                 disp(nbr.type);
%             end
            %box.showBox();
            %%%%%%%%%%%%%%%%%%%%%% FIRST SPLIT:
            
%             rootBox = s.rootBox;
%             disp(rootBox.features);
%             s.split(rootBox);
%             for i = 1:length(rootBox.child(4).features)
%                 disp(rootBox.child(4).features{i})
%             end
            
            %rootBox.showBox();
            
            
            %%%%%%%%%%%%%%%%%%%%%% SECOND SPLIT:
%             box = s.findBox(9,1);
%             disp('second split');
%             disp(box.features);
            %s.split(box);
            %{
            %%%%%%%%%%%%%%%%%%%%%% THIRD SPLIT:
            box = s.findBox(9,1);
            s.split(box);
            
            box = s.findBox(8.125,0.625);
            s.split(box);
            
            %box = s.findBox(2.5,2.5);
            box = s.findBox(8.13,1.9);
            nbrs = s.getNeighbours(box);
            %}
           % disp(box);
            %alpha(0.3);
            nbrs = s.getNeighbours(box);
             %s.displaySubDiv();
%             s.env.showEnv();
            %alpha(1);
            %s.plotNbrs(box,nbrs); % Assuming 1-N, 2-W, 3-S, 4-E, dir needs to be impemented
            %alpha(1);
            s.displaySubDiv();
            %alpha(1);
            %s.env.showEnv(false);
            l = s.getRelvantLeaves(s.rootBox);
            
            
           
            %s.plotLeaf(rootBox, BoxType.MIXED);
        end
    end
end
