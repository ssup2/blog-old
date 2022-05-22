---
title: Programmers / 게임 맵 최단거리
category: Coding Test
date: 2022-05-16T12:00:00Z
lastmod: 2022-05-16T12:00:00Z
comment: true
adsense: true
---

### Problem

* Link
  * [https://programmers.co.kr/learn/courses/30/lessons/1844](https://programmers.co.kr/learn/courses/30/lessons/1844)

* Description
  * 게임 맵 최단거리 찾기

* Type
  * 완전 탐색 / BFS

### Solution 1

{% highlight java linenos %}
import java.util.LinkedList;

class Solution {
    public int solution(int[][] maps) {
        // Get map size
        int mapX = maps.length;
        int mapY = maps[0].length;
        System.out.printf("mapX:%d, mapY:%d", mapX, mapY);
        
        // Init vars
    	  boolean[][] visitedMap = new boolean[mapX][mapY];
        LinkedList<Position> nextQueue = new LinkedList<>();
        
        // Find path
        visitedMap[0][0] = true;
        nextQueue.offer(new Position(0, 0, 1));
        while(nextQueue.size() != 0) {
            // Get next position
            Position nextPos = nextQueue.poll();
            int nextX = nextPos.getX();
            int nextY = nextPos.getY();
            int nextDepth = nextPos.getDepth();
            
            // Check this position is goal
           	if (nextX == mapX - 1 && nextY == mapY - 1) {
                return nextDepth;
            }
            
            // Enqueue next position to visit
            if ((nextX+1 < mapX) && (maps[nextX+1][nextY] == 1) && (!visitedMap[nextX+1][nextY])){
                visitedMap[nextX+1][nextY] = true;
                nextQueue.offer(new Position(nextX+1, nextY, nextDepth+1));
            } 
            if ((nextY+1 < mapY) && (maps[nextX][nextY+1] == 1) && (!visitedMap[nextX][nextY+1])){
                visitedMap[nextX][nextY+1] = true;
                nextQueue.offer(new Position(nextX, nextY+1, nextDepth+1));
            } 
            if ((nextX-1 >= 0) && (maps[nextX-1][nextY] == 1) && (!visitedMap[nextX-1][nextY])){
                visitedMap[nextX-1][nextY] = true;
                nextQueue.offer(new Position(nextX-1, nextY, nextDepth+1));
            } 
            if ((nextY-1 >= 0) && (maps[nextX][nextY-1] == 1) && (!visitedMap[nextX][nextY-1])){
                visitedMap[nextX][nextY-1] = true;
                nextQueue.offer(new Position(nextX, nextY-1, nextDepth+1));
            }
        }
        
        // Not reachable
        return -1;
    }
}

class Position {
    public int x;
    public int y;
    public int depth;
    
    public Position(int x, int y, int depth) {
        this.x = x;
        this.y = y;
        this.depth = depth;
    }
    
    public int getX() {
        return x;
    }
    
    public int getY() {
        return y;
    }
    
    public int getDepth() {
        return depth;
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">Solution 1</figcaption>
</figure>

* Description
  * BFS를 이용하여 탐색
  * DFS를 이용하여 탐색하면 모든 경로를 탐색후 최단거리 판별이 가능하지만, BFS를 이용하면 모든 경로를 탐색할 필요가 없음

* Time Complexity
  * O(len(mapX) * len(mapY))
  * Map을 한번씩만 방문하면서 경로 탐색을 수행하기 때문에 Map의 크기에 비례

* Space Complexity
  * O(len(mapX) * len(mapY))
  * 함수의 입력값으로 Map의 크기 만큼 Memory 이용
