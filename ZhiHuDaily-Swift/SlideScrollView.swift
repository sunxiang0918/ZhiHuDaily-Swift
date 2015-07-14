

import UIKit
import Haneke

protocol SlideScrollViewDelegate {
    
    func SlideScrollViewDidClicked(index:Int)
    
}

class SlideScrollView: UIView,UIScrollViewDelegate {

    var viewSize:CGRect = CGRect()
    var scrollView:UIScrollView = UIScrollView()
    
    var pageControl:UIPageControl = UIPageControl()
    var currentPageIndex:Int = 0
    var noteTitle:UILabel = UILabel()
    
    var _topNewsArray:[NewsVO]?
    
    var delegate:SlideScrollViewDelegate?
    
    func initWithFrameRect(rect:CGRect,topNewsArray:[NewsVO]?) ->AnyObject {
//        var view:UIView = UIView(frame:rect)
        
        if let topNews = topNewsArray{
            self.userInteractionEnabled=true;
            
            var tempArray:[NewsVO] = []
            
            for t in topNews {
                tempArray.append(t)
            }
            
            tempArray.insert(topNews[topNews.count-1], atIndex:0)
            tempArray.append(topNews[0])
            _topNewsArray = tempArray
            viewSize=rect;
            let pageCount:Int=tempArray.count
            scrollView=UIScrollView(frame:CGRect(origin: CGPoint(x: 0,y: 0),size: CGSize(width: viewSize.size.width,height: viewSize.size.height)))
            scrollView.pagingEnabled = true
//            var contentWidth = 320*pageCount
            
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
            
            scrollView.scrollEnabled = true
            scrollView.pagingEnabled = true
            scrollView.scrollsToTop = false
            scrollView.delegate = self
            
            for var i=0; i<pageCount; i++ {
                let newsVO:NewsVO=_topNewsArray![i]
                
                let imgView:UIImageView=UIImageView()
                
                let viewWidth = Int(viewSize.size.width)*i
                imgView.frame = CGRect(origin: CGPoint(x: viewWidth,y: 0),size: CGSize(width: viewSize.size.width,height: viewSize.size.height))

                var imageUrl:String?=nil
                if let images = newsVO.images {
                    imageUrl = images[0]
                }
                
                imgView.hnk_setImageFromURL(NSURL(string: imageUrl ?? "")!)
                
                imgView.contentMode = UIViewContentMode.ScaleToFill
                imgView.userInteractionEnabled = true
                
                imgView.transform = CGAffineTransformMakeTranslation(0, -100);
                
                imgView.tag = i
                
                let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "imagePressed:")
                
                tap.numberOfTapsRequired = 1
                tap.numberOfTouchesRequired = 1
                imgView.addGestureRecognizer(tap)
                scrollView.addSubview(imgView)
                
            }
            
            scrollView.contentOffset = CGPoint(x:viewSize.size.width, y:0)
            
            self.addSubview(scrollView)
            
            //文字层
            let myHeight:Float = 24;
            
            let shadowImg:UIImageView = UIImageView()
            shadowImg.frame = CGRect(origin: CGPoint(x: 0,y: 130),size: CGSize(width: 320,height: 80))
            shadowImg.image = UIImage(named:"shadow.png")
            self.addSubview(shadowImg)
            
            let noteView:UIView = UIView(frame:CGRect(origin:CGPoint(x:0, y:CGFloat(IN_WINDOW_HEIGHT-25)),size:CGSize(width:320,height:CGFloat(myHeight))));
            noteView.userInteractionEnabled = false;
            noteView.backgroundColor = UIColor(red:0/255.0,green:0/255.0,blue:0/255.0,alpha:0)
            
            let pageControlWidth:Float = (Float(pageCount-2))*10.0+Float(40)
            let pagecontrolHeight:Float = myHeight
            
            pageControl = UIPageControl(
                frame:CGRect(origin:CGPoint(x:CGFloat(Float(self.viewSize.size.width)/2-Float(pageControlWidth/2)), y:0),
                    size:CGSize(width:CGFloat(pageControlWidth),height:CGFloat(pagecontrolHeight))))
            
            pageControl.currentPage=0;
            pageControl.numberOfPages=(pageCount-2);
            noteView.addSubview(pageControl)
            
            noteTitle = UILabel()
            noteTitle.textColor = UIColor.whiteColor()
            noteTitle.font = UIFont.boldSystemFontOfSize(FONT_SIZE)
            noteTitle.numberOfLines = 0
            noteTitle.lineBreakMode = NSLineBreakMode.ByCharWrapping
            
            noteTitle.text = self._topNewsArray![1].title
            noteTitle.frame = CGRect(origin: CGPoint(x: 10,y: CGFloat(IN_WINDOW_HEIGHT-50-20)),size: CGSize(width: UIScreen.mainScreen().bounds.width-75,height: 50))
            
            //增加底部的Mask
            let maskImage = UIImage(named: "Home_Image_Mask")
            let maskImageView = UIImageView(frame: CGRectMake(0, CGFloat(IN_WINDOW_HEIGHT-75), viewSize.size.width, 75))
            maskImageView.image = maskImage
            //            maskImageView.backgroundColor = UIColor.blackColor()
            self.addSubview(maskImageView)
            
            self.addSubview(noteTitle)
            
            self.addSubview(noteView)
            
            NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "autoShowNextPage", userInfo: nil, repeats: true)
            
        }
        
        return self
    }
    
    func autoShowNextPage() {

        if pageControl.currentPage + 1 < _topNewsArray!.count-2 {
            currentPageIndex = pageControl.currentPage + 1
            self.changeCurrentPage()
        }else{
            currentPageIndex = 0;
            self.changeCurrentPage()
        }
    }
    
    func changeCurrentPage (){
        let offX = Float(scrollView.frame.size.width) * Float(currentPageIndex+1)
        scrollView.setContentOffset(CGPoint(x:CGFloat(offX), y:CGFloat(scrollView.frame.origin.y)), animated:true)
        self.scrollViewDidScroll(scrollView);
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //感觉swift算数运算的时候好麻烦啊，一个运算里必须要所有的值都保持一致才行，所以一个运算才变成了下面这一大段难看的代码，本来应该是这样的：
        // var page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1
        //应该是我没搞明白swift的真谛吧，我不相信有这么麻烦，求大神指教啊

        let pageWidth:Int = Int(scrollView.frame.size.width)
        let offX:Int = Int(scrollView.contentOffset.x)
        let a = offX - pageWidth / 2 as Int
        let b = a / pageWidth as Int
        let c = floor(Double(b))
        let page:Int = Int(c) + 1
        
        currentPageIndex=page
        pageControl.currentPage=(page-1)
        var titleIndex=page-1
        if (titleIndex==_topNewsArray!.count-2) {
        titleIndex=0;
        }
        if (titleIndex<0) {
        titleIndex=_topNewsArray!.count-2-1;
        }
        noteTitle.text = self._topNewsArray![titleIndex+1].title

    }
    
    func imagePressed (tap:UITapGestureRecognizer){
        delegate?.SlideScrollViewDidClicked(tap.view!.tag)
    }

}
