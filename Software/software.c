#include <assert.h>
#include <getopt.h>
#include <limits.h>
#include <signal.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>
#include <time.h>
#include <omp.h>

#define 	FILE_NAME  									"coo.txt"	
#define		E														10000			//number of ratings
#define		U														100				//number of users
#define		V														100 			//number of items	
#define 	max_shard_size							2500000
#define		matching_no									26723

#define		Interval_size								32768
#define		p														8

#define		H														32
#define		alpha												0.0001		
#define  	beta												0.999998

typedef struct{
	unsigned int		user;
	unsigned int	 	item;
	unsigned char		rating;	
} Edge;

typedef struct{
	int new_id;
	int pid;	
	int degree;
} Vertex;

typedef struct{
	int size;	
	int degree;
} Partition;

int	edge_coloring(Edge * shard, int shard_size, int * M_number, int * matching_pointer){
		int user_degree[Interval_size];
		int item_degree[Interval_size];
		int i, j, k, m, n;	
		int matching_id;
		int temp_matching_size;
		int color_num=0;
		int user, item;
		for(i=0; i<Interval_size; i++){
			user_degree[i]=0;
			item_degree[i]=0;	
		}  
		for(i=0; i<shard_size; i++){	
			user = shard[i].user%Interval_size;
			item = shard[i].item%Interval_size;		 
			user_degree[user]++;
			item_degree[item]++;	
			if(user_degree[user]>color_num) color_num=user_degree[user];
			if(item_degree[item]>color_num) color_num=item_degree[item];
		}	
		
		int *matching_size = (int*) malloc(sizeof(int)*color_num);
		int *Prefix_sum_of_matching_size = (int*) malloc(sizeof(int)*color_num);
		int *No_of_edges_has_been_colored = (int*) malloc(sizeof(int)*color_num);
		unsigned char **user_color = (unsigned char **)	malloc(sizeof(unsigned char*)*Interval_size);
		unsigned char **item_color = (unsigned char **)	malloc(sizeof(unsigned char*)*Interval_size);
		
		*M_number=(*M_number<color_num) ? color_num : *M_number;
		
		for(i=0; i<color_num; i++){
			matching_size[i] =0;
			Prefix_sum_of_matching_size[i] = 0;
			No_of_edges_has_been_colored[i] =0;
		}
		for(i=0; i<Interval_size; i++){
			user_color[i] = (unsigned char *)	malloc(sizeof(unsigned char)*color_num);
			item_color[i] = (unsigned char *)	malloc(sizeof(unsigned char)*color_num);
		}
		for(i=0; i<Interval_size; i++){
			for(j=0; j<color_num; j++){
				user_color[i][j] = 0;
				item_color[i][j] = 0;
			}
		}
		
		Edge * shard_copy = (Edge *) malloc(sizeof(Edge)* shard_size);
		int * edge_color = (int *) malloc(sizeof(int)* shard_size);
		
					
		#pragma omp parallel for shared(shard, edge_color, shard_copy) private(i) schedule(static, shard_size/16)
		for(i=0; i<shard_size; i++){
			edge_color[i]=-1;
			shard_copy[i]=shard[i];
		}
			 		
		int current_color = 0;
		for(i=0; i<shard_size; i++){
			matching_id = -1;
			temp_matching_size = Interval_size;
			user = shard[i].user%Interval_size;
			item = shard[i].item%Interval_size;	
			for(j=0; j<color_num; j++){
				if(user_color[user][(j+current_color)%color_num] == 0 && item_color[item][(j+current_color)%color_num] == 0){
					if(matching_size[j]<temp_matching_size){
						temp_matching_size = matching_size[j];
						matching_id = (j+current_color)%color_num;
						break;
					}				
				}
			}
				
			if(matching_id != -1){				
				edge_color[i]=matching_id;
				user_color[user][matching_id] =1;	
				item_color[item][matching_id] =1;
				matching_size[matching_id] ++;
				current_color = matching_id;
			}
		}
						
		matching_pointer[0] = 0;
		for(i=1; i<color_num; i++){
			Prefix_sum_of_matching_size[i] = Prefix_sum_of_matching_size[i-1]+matching_size[i-1];
			matching_pointer[i] = Prefix_sum_of_matching_size[i];
		}		
		int new_shard_size =Prefix_sum_of_matching_size[color_num-1]+matching_size[color_num-1];								 						
		matching_pointer[i] = new_shard_size;
			
		for(i=0; i<new_shard_size; i++){
				matching_id = edge_color[i];
				if(matching_id>=0){
					shard[Prefix_sum_of_matching_size[matching_id]+No_of_edges_has_been_colored[matching_id]]=shard_copy[i];		
					No_of_edges_has_been_colored[matching_id]++;
				}	
		}
						
		free(matching_size);
		for(i=0; i<Interval_size; i++){ 
			free(user_color[i]);
			free(item_color[i]);
		}
		free(user_color);
		free(item_color);
		free(shard_copy);
		free(edge_color);
		free(No_of_edges_has_been_colored);
		free(Prefix_sum_of_matching_size);
		
		return color_num;
}

int main(int argc, char *argv[]){		
		FILE *fp;
		FILE	*fp_write;
		int i, j, k, n, m;
		unsigned int u1, u2, u3;			
		struct timespec start, stop; 
		double exe_time;		
		int x, y;	
		Edge 	*edges 	= 	(Edge*)	malloc(sizeof(Edge)*E);
		Vertex *users	=  (Vertex*)	malloc(sizeof(Vertex)*U);
		Vertex *items	=  (Vertex*)	malloc(sizeof(Vertex)*V);
		
		float **user_FV = (float **)malloc(sizeof(float*)*U);
		float **item_FV = (float **)malloc(sizeof(float*)*V);
		
		for(i=0; i<U; i++) user_FV[i] = (float *)malloc(sizeof(float)*H);		
		for(i=0; i<V; i++) item_FV[i] = (float *)malloc(sizeof(float)*H);
		
		srand((unsigned int)time(NULL));	
		for(i=0; i<U; i++) for(j=0; j<H; j++) user_FV[i][j] =  (float) rand() / (RAND_MAX);
		for(i=0; i<V; i++) for(j=0; j<H; j++) item_FV[i][j] = (float) rand() / (RAND_MAX);
		
		int u_max=0;
		int i_max=0;
		
		for(i=0; i<U; i++){
			users[i].new_id = 0;
			users[i].degree = 0;
			users[i].pid = 0;		
		}
		
		for(i=0; i<V; i++){
			items[i].new_id = 0;
			items[i].degree = 0;	
			items[i].pid = 0;	
		}
		
		if ((fp=fopen(FILE_NAME,"r"))==NULL)
			printf("Cannot open file. Check the name.\n"); 
		else {
    	for(i=0;i<E;i++){
				if(fscanf(fp,"%d %d %d\n",&u1,&u2,&u3)!=EOF){
					edges[i].user=u1;
					edges[i].item=u2;
					edges[i].rating=u3;
					if(u1>u_max) u_max = u1;
					if(u2>i_max) i_max = u2;
				}
			}			
			fclose(fp);
		}
		
		
		int user_partitions_no = U/Interval_size+(U>Interval_size*(int)(U/Interval_size));
		int item_partitions_no = V/Interval_size+(V>Interval_size*(int)(V/Interval_size));
		if(V<Interval_size) item_partitions_no = 1;
		
		Partition *user_partitions	=  (Partition*)	malloc(sizeof(Partition)*user_partitions_no);
		Partition *item_partitions	=  (Partition*)	malloc(sizeof(Partition)*item_partitions_no);
		
		for(i=0; i<user_partitions_no; i++){
				user_partitions[i].degree = 0;
				user_partitions[i].size = 0;						
		}	
		
		for(i=0; i<item_partitions_no; i++){
				item_partitions[i].degree = 0;
				item_partitions[i].size = 0;						
		}
		
		int pid, minDegree;
									
		
		omp_set_num_threads(16);
		

		for(i=0;i<E;i++){	
			users[edges[i].user].degree++;
			items[edges[i].item].degree++;
		}	
		#pragma omp parallel private(i,j, pid, minDegree)
		{			
			#pragma omp sections nowait
     	{
				//partition U
				#pragma omp section
				for(i=0;i<U; i++){	
					pid = 0;
					minDegree = E;
					for(j=0; j<user_partitions_no; j++){
						if(user_partitions[j].size<Interval_size & minDegree>user_partitions[j].degree){
							pid = j;
							minDegree=user_partitions[j].degree;
						}
					}
					user_partitions[pid].degree += users[i].degree;
					users[i].pid=pid; 
					users[i].new_id = pid*Interval_size+user_partitions[pid].size;
					user_partitions[pid].size += 1;
				}
				//partition V
				#pragma omp section
				for(i=0;i<V; i++){	
					pid = 0;
					minDegree = E;
					for(j=0; j<item_partitions_no; j++){
						if(item_partitions[j].size<Interval_size & minDegree>item_partitions[j].degree){
							pid = j;
							minDegree=item_partitions[j].degree;
						}
					}
					item_partitions[pid].degree += items[i].degree;
					items[i].new_id = pid*Interval_size+item_partitions[pid].size;
					items[i].pid=pid; 
					item_partitions[pid].size += 1;
				}
			}
		}	
		
		omp_set_num_threads(16);
		
		//----------------------------------------------------------------------------
		// Edge partitioning

		Edge 	** shards = (Edge**)	malloc(sizeof(Edge*)*user_partitions_no*item_partitions_no);
		int* shard_size	=	(int*)		malloc(sizeof(int)*user_partitions_no*item_partitions_no);
		int** matching_pointer = (int**)	malloc(sizeof(int*)*user_partitions_no*item_partitions_no);
		int* 	number_of_matchings = (int*)	malloc(sizeof(int)*user_partitions_no*item_partitions_no);
		
		for(i=0; i<user_partitions_no*item_partitions_no; i++){
			shards[i] = (Edge*)	malloc(sizeof(Edge)*max_shard_size);
			matching_pointer[i] = (int*) malloc(sizeof(int)*matching_no);
			for(j=0; j<matching_no; j++) matching_pointer[i][j]=0; 				
			shard_size[i] = 0;
			number_of_matchings[i]=0;	
		}
				
		
		#pragma omp parallel for shared(edges) private(i) schedule(static, E/16)
		for(i=0; i<E;	i++){					 
			 edges[i].user = users[edges[i].user].new_id;
			 edges[i].item = items[edges[i].item].new_id;			 			 
		}	
		
		for(i=0; i<E;	i++){		
			 x =   edges[i].user/Interval_size;
			 y =   edges[i].item/Interval_size;			 
			 shards[x*item_partitions_no+y][shard_size[x*item_partitions_no+y]] = edges[i];
			 shard_size[x*item_partitions_no+y]++;			
		}	
					
				
		int max =0;
		int min =E;
		
		for(i=0; i<user_partitions_no; i++){
			for(j=0; j<item_partitions_no; j++){				
				if (max < shard_size[i*item_partitions_no+j]) max =  shard_size[i*item_partitions_no+j];
				if (min > shard_size[i*item_partitions_no+j]) min =  shard_size[i*item_partitions_no+j]; 				
			}
		}	
					
		//----------------------------------------------------------------------------
		// Edge coloring		
		
		int M_number = 0;				
		
		int new_edge_no = 0;
		
		//omp_set_num_threads(32);
		//#pragma omp parallel for shared(shards,shard_size) private(i) schedule(static)
		for(i=0; i<user_partitions_no*item_partitions_no; i++){			
				number_of_matchings[i] = edge_coloring(shards[i], shard_size[i], &M_number, matching_pointer[i]);				
		}
		
		for(i=0; i<user_partitions_no*item_partitions_no; i++){		
				new_edge_no+=shard_size[i] ;
		}		
				
		
		k=0;
		for(i=0;i<user_partitions_no*item_partitions_no;i++){		
			for(j=0; j<shard_size[i]; j++){
				edges[k] = shards[i][j];
				k++;
			}			
		}				
		
		
	
		float error;
		float total_error;
		float total_error_old=10000000000000000.0;
		float prediction;
		float temp_u[H];
		float temp_v[H];
		Edge 	edgeA;
		int 	start_pos;
		int 	end_pos;
		int 	chunk;
		
		printf("start processing\n");
		omp_set_num_threads(16);		
		
		
		
		for(m=0; m<10; m++){
			total_error = 0;
			for(i=0; i<user_partitions_no*item_partitions_no; i++){
				for(j=0; j<number_of_matchings[i]; j++){
					start_pos = matching_pointer[i][j];
					end_pos = matching_pointer[i][j+1];
					if(end_pos>start_pos){
						chunk = end_pos-start_pos;						
						#pragma omp parallel shared(shards,user_FV,item_FV,i,start_pos) private(k,edgeA,prediction,n,error,temp_u,temp_v) reduction(+:total_error)
   					{							
							#pragma omp for schedule(static) 
							for(k=0; k<chunk; k++){						
								edgeA = shards[i][k+start_pos];																
								prediction = 0;			
								for(n=0; n<H; n++){				
									temp_u[n] = user_FV[edgeA.user][n];
									temp_v[n] = item_FV[edgeA.item][n];
									prediction+= temp_u[n]*temp_v[n];
								}	
								error = edgeA.rating-prediction;
								for(n=0; n<H; n++){
									user_FV[edgeA.user][n] = beta*temp_u[n] + alpha*error*temp_v[n];
									item_FV[edgeA.item][n] = beta*temp_v[n] + alpha*error*temp_u[n];	
								}
								total_error += error*error;												
							}
						}
					}
				}			
			}				
		}
		
		free(users);
		free(items);
		free(edges); 
		return 1;
}
	