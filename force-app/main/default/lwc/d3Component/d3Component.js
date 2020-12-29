import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import D3 from '@salesforce/resourceUrl/d3';
export default class D3Component extends LightningElement {
    svgWidth = 625;
    svgHeight = 312.5;
    d3Initialized = false;
    renderedCallback() {
        if (this.d3Initialized) {
            return;
        }
        this.d3Initialized = true;

        Promise.all([
            loadScript(this, D3)
        ])
            .then(() => {
                this.initializeD3();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading D3',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });
    }

    initializeD3() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success loading D3',
                message: this.message,
                variant: 'success'
            })
        );
        const svg = d3.select(this.template.querySelector('svg.d3'));
        svg.attr("style","margin: 20px");
        let g;
        let data = [4, 8, 15, 16, 23, 42, 50];
        const tooltip = d3.select(this.template.querySelector('.tooltip'));
         tooltip.style("position", "absolute")
            .style("z-index", "10")
            .style("visibility", "hidden")
            .style("background", "#fff")
            .style("top","55px")
            .style("left" ,"76.7891px")
            .style("padding","5px 0")
            .text("a simple tooltip");

        svg.append("text")
             .attr("transform", "translate(300 ,300)")
             .attr("style","text-anchor:middle")
             .attr("style","font-size:16px" )
             .attr("style","font-family:inherit")
             .text("Resilience")

         svg.append("text")
             .attr("transform", "rotate(-90)")
             .attr("y", "-3")
             .attr("x", "-179.25")
             .attr("dy","1em")
             .attr("style","text-anchor:middle")
             .attr("style","font-size:16px" )
             .attr("style","font-family:inherit")
             .attr("style","padding:30px")
             .text("Collaboration")

            g = svg.append("g")
            .attr("style", "transform:translate(50px, 10px)")
       
            g.append("rect")
               .attr("x","282.5" )
               .attr("y","0" )
               .attr("width","282.5" )
               .attr("height","126.25" )
               .attr("fill","rgb(198, 239, 50)")
               .attr("style","opacity:0.5")

               g.append("rect")
               .attr("x","0" )
               .attr("y","0" )
               .attr("width","282.5" )
               .attr("height","126.25" )
               .attr("fill","rgb(244, 227, 127)")
               .attr("style","opacity:0.3")

               g.append("rect")
               .attr("x","0" )
               .attr("y","126.25" )
               .attr("width","282.5" )
               .attr("height","126.25" )
               .attr("fill","rgb(255, 192, 203)")
               .attr("style","opacity:1")

               g.append("rect")
               .attr("x","282.5" )
               .attr("y","126.25" )
               .attr("width","282.5" )
               .attr("height","126.25" )
               .attr("fill","rgb(129, 205, 255)")
               .attr("style","opacity:0.5")

               g.append("image")
                 .attr("class", "image-1")
                 .attr("href","https://storage.googleapis.com/perfit/dp/default")
                 .attr("width","16")
                 .attr("height","16")
                 .attr("x","298.1818181818182")
                 .attr("y","119.85714285714283")
                 .attr("style","fill: rgb(31, 119, 180)")

                 g.append("image")
                 .attr("class", "image-1")
                 .attr("href","https://storage.googleapis.com/perfit/dp/default")
                 .attr("width","16")
                 .attr("height","16")
                 .attr("x","195.45454545454547")
                 .attr("y","54.928571428571416")
                 .attr("style","fill: rgb(255, 127, 14)")

                 g.append("image")
                 .attr("class", "image-1")
                 .attr("href","https://storage.googleapis.com/perfit/dp/default")
                 .attr("width","16")
                 .attr("height","16")
                 .attr("x","246.8181818181818")
                 .attr("y","83.78571428571429")
                 .attr("style","fill: rgb(44, 160, 44)")

                 g.append("image")
                 .attr("class", "image-1")
                 .attr("href","https://storage.googleapis.com/perfit/dp/default")
                 .attr("width","16")
                 .attr("height","16")
                 .attr("x","400.90909090909093")
                 .attr("y","134.28571428571428")
                 .attr("style","fill: rgb(31, 119, 180)")

                 g.append("image")
                 .attr("class", "image-1")
                 .attr("href","https://storage.googleapis.com/perfit/dp/default")
                 .attr("width","16")
                 .attr("height","16")
                 .attr("x","298.1818181818182")
                 .attr("y","220.85714285714286")
                 .attr("style","fill: rgb(214, 39, 40)")

                 g.append("image")
                 .attr("class", "image-1")
                 .attr("href","https://storage.googleapis.com/perfit/dp/default")
                 .attr("width","16")
                 .attr("height","16")
                 .attr("x","144.0909090909091")
                 .attr("y","155.92857142857142")
                 .attr("style","fill: rgb(148, 103, 189)")

                 g.append("image")
                 .attr("class", "image-1")
                 .attr("href","https://storage.googleapis.com/perfit/dp/default")
                 .attr("width","16")
                 .attr("height","16")
                 .attr("x","246.8181818181818")
                 .attr("y","127.07142857142858")
                 .attr("style","fill: rgb(140, 86, 75)")

                g.selectAll(".image-1")
                   .data(data)
                   .enter()
                   .on("mouseover", function(d){
                       console.log(d);
                   });
                   
                //  .on("mousemove", function () {
                //      return tooltip.style("top", (d3.event.pageY - 10) + "px").style("left", (d3.event.pageX + 10) + "px");
                //  })
                //  .on("mouseout", function () {
                //      return tooltip.style("visibility", "hidden");
                //  });;


    }
  
}