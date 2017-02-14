class Parent {
    public void print(){
        System.out.println("Parent");
    }
}
 
class Child extends Parent {
    public void print(){
        System.out.println("Child");
    }
}
 
public class BlogMain {
    public static void main(String[] args){
        Parent iparent = new Parent();
        Parent ichild = new Child();
        
        iparent.print();
        ichild.print();
    }
}
