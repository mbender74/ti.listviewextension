# ti.listviewextension

## Description

TiUIListView Extension for iOS (Titanium Module)

Improves ListView 

Just add module in **tiapp.xml** no further steps needed!


API is exactly as:
https://titaniumsdk.com/api/titanium/ui/listview.html


## additional properties

* `scrollIndicatorInsets:{top:0,bottom:0} ` - separatly adjust scrollIndicatorInsets from contentInsets

* `scrollToBottomOnce:BOOL ` - scroll without delay and animation to the end of the listview after first data fill


* `snappingEnabled:BOOL ` - scroll always to the next visible item (item will be visible full

* `pagingEnabled:BOOL ` - scrolls in pageing mode (like Ti.UI.scrollableView)


## additional event listener

* `scroll ` - returns current contentOffset and contentSize (fires as long the listView is scrolling - in contrast to 'scrolling' which is only fired when the users ends dragging

## additional method

* `listView.contentSize ` - returns the contentSize (height/width) of the listView




## Example

```js

var win = Ti.UI.createWindow({backgroundColor: 'green'});

// Create a custom template that displays an image on the left,
// then a title next to it with a subtitle below it.
var myTemplate = {
    properties: {      
        height:90,
        backgroundColor:'transparent',
    },
    childTemplates: [
        {                            
            type: 'Ti.UI.View', 
            bindId: 'container',           
            properties: {            
                width: Ti.UI.FILL, height: Ti.UI.SIZE, left: 0, bottom:0, top:0, backgroundColor: 'transparent',        layout:'horizontal'
         },
            childTemplates: [
                {                            // Image justified left
                    type: 'Ti.UI.ImageView', // Use an image view for the image
                    bindId: 'pic',           // Maps to a custom pic property of the item data
                    properties: {            // Sets the image view  properties
                        width: Ti.UI.SIZE, height: 50, left: 10, bottom:10, top:10, backgroundColor: 'transparent', noTransparency:false
                    }
                },
                {                            
                    type: 'Ti.UI.View', 
                    bindId: 'labelscontainer',           
                    properties: {            
                        width: Ti.UI.FILL, height: Ti.UI.SIZE, left: 10, bottom:10, top:10, backgroundColor: 'transparent'
                    },
                    childTemplates: [
                        {                            // Title
                            type: 'Ti.UI.Label',     // Use a label for the title
                            bindId: 'info',          // Maps to a custom info property of the item data
                            properties: {            // Sets the label properties
                                color: 'black',
                                height:Ti.UI.SIZE,
                                width:Ti.UI.SIZE,
                                backgroundColor: 'transparent',
                                font: { fontFamily:'Arial', fontSize: 20, fontWeight:'bold' },
                                left: 10, top: 0,
                            }
                        },
                        {                            // Subtitle
                            type: 'Ti.UI.Label',     // Use a label for the subtitle
                            bindId: 'es_info',       // Maps to a custom es_info property of the item data
                            properties: {            // Sets the label properties
                                color: 'gray',
                                height:Ti.UI.SIZE,
                                width:Ti.UI.SIZE,
                                backgroundColor: 'transparent',
                                font: { fontFamily:'Arial', fontSize: 14 },
                                left: 10, top: 25,
                            }
                        }
                    ]
                }
            ]
        }       
    ]  
};

var listView = Ti.UI.createListView({
    top:50,
    bottom:50,
    left:0,
    right:0,
    height:Ti.UI.FILL,
    width:Ti.UI.FILL,
    lazyLoadingEnabled:false,
    templates: { 'template': myTemplate },
    contentInsets:{top:0,bottom:0},
    scrollIndicatorInsets:{top:20,bottom:40},
    sectionHeaderTopPadding:0,
    scrollToBottomOnce:true,
    snappingEnabled:false,
    pagingEnabled:false,
    defaultItemTemplate: 'template'
});



 listView.addEventListener("scroll", function(e){
    // console.log(" ");
    // console.log("scroll event: "+JSON.stringify(e.contentOffset)+" "+JSON.stringify(e.contentSize));
 });


 listView.addEventListener("scrolling", function(e){
//    // console.log(" ");
//    // console.log(" ");
     console.log("scrolling event: "+JSON.stringify(e));
 });


 function createDynamicHeaderViewWithLabel(text,color){

    var header = Ti.UI.createView({
        width: Ti.UI.FILL,
        height: 60,
        backgroundColor:color
    });
    var lbl = Ti.UI.createLabel({
        width: Ti.UI.SIZE,
        height:Ti.UI.SIZE,
        color:'white',
        text:text,
        font:{
            fontSize: 26,
            fontWeight: 'bold'
        },
        backgroundColor:color,
        textAlign:Ti.UI.TEXT_ALIGNMENT_LEFT,
        shadowColor: 'black',
    	shadowOffset: {x:1, y:1},
	    shadowRadius: 4
    });
    header.add(lbl);

    return header;
 }



var sections = [];

var fruitDataSet = [
    // the text property of info maps to the text property of the title label
    // the text property of es_info maps to text property of the subtitle label
    // the image property of pic maps to the image property of the image view
    { info: {text: 'Apple'}, es_info: {text: 'Manzana'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Banana'}, es_info: {text: 'Banana'}, pic: {image: '/images/heart2.png',animated:false}}
];

var fruitSection = Ti.UI.createListSection({ headerView: createDynamicHeaderViewWithLabel('Header 1','yellow'), items: fruitDataSet});
sections.push(fruitSection);

var vegDataSet = [
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},
    { info: {text: 'Carrot'}, es_info: {text: 'Zanahoria'}, pic: {image: '/images/heart1.png',animated:false}},
    { info: {text: 'Potato'}, es_info: {text: 'Patata'}, pic: {image: '/images/heart5.png',animated:false}},

  ];
var vegSection = Ti.UI.createListSection({ headerView: createDynamicHeaderViewWithLabel('Header 2','red'), items: vegDataSet});
sections.push(vegSection);

var grainDataSet = [
    { info: {text: 'Corn'}, es_info: {text: 'Maiz'}, pic: {image: '/images/heart3.png',animated:false}},
    { info: {text: 'Rice'}, es_info: {text: 'Arroz'}, pic: {image: '/images/heart4.png',animated:false}}
];
var grainSection = Ti.UI.createListSection({ headerView: createDynamicHeaderViewWithLabel('Header 3','blue'), items: grainDataSet});
sections.push(grainSection);
listView.sections = sections;

win.add(listView);
win.open();


setTimeout(function(){
    console.log("contentSize: "+JSON.stringify(listView.contentSize));
},2280);
```

