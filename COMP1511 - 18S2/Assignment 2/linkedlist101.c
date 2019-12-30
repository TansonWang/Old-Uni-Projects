//linked list
#include <stdlib.h>
#include <math.h>
#include <stdio.h>

typedef struct node {
	struct node *next;
	int data;
} *node;

void addtolistend(node head, node end);

node createNode (int data) {
	node n;
	n = calloc(1, sizeof(struct node));
	n->data = data;
	n->next = NULL;
	return n;
}

int main () {

		node head;
		head = calloc(1, sizeof(struct node));
		if (head == NULL) {
			return 1;
		}
		head->data = 1;
		head->next = NULL;

	int i=0;
	while (i<5) {
		addtolistend(head, createNode(i));
		i++;
	}
	addtolistend(head, createNode(1));
	addtolistend(head, createNode(100));

	node now = head;
	while (now != NULL) {
		
		printf("%d\n", now->data);
		now = now->next;

		
	}

}

void addtolistend(node head, node end) {
	node curr = head;
	while(curr->next != NULL) {
		curr = curr->next;
	}
	curr->next = end;
}
