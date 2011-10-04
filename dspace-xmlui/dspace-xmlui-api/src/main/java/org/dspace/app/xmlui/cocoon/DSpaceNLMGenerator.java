/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.xmlui.cocoon;

import java.io.IOException;
import java.sql.SQLException;

import org.apache.cocoon.ProcessingException;
import org.apache.cocoon.ResourceNotFoundException;
import org.apache.cocoon.generation.AbstractGenerator;
import org.dspace.app.xmlui.utils.ContextUtil;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.content.ItemIterator;
import org.dspace.content.Collection;
import org.dspace.content.crosswalk.CrosswalkException;
import org.dspace.content.crosswalk.DisseminationCrosswalk;
import org.dspace.content.crosswalk.XSLTCrosswalk;
import org.dspace.content.crosswalk.XSLTDisseminationCrosswalk;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.core.PluginManager;
import org.dspace.handle.HandleManager;
import org.jdom.DocType;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.output.Format;
import org.jdom.output.DOMOutputter;
import org.jdom.output.SAXOutputter;
import org.jdom.output.XMLOutputter;
import org.jdom.transform.XSLTransformer;
import org.xml.sax.SAXException;

/**
 * Generate an NLM aggregation of a DSpace Item. The object to be rendered should be an item identified by pasing 
 * in one of the two parameters: handle or internal. 

 * @author Alexey Maslov
 * @contributor Jason Stirnaman
 */


public class DSpaceNLMGenerator extends AbstractGenerator
{	
	public void generate() throws IOException, SAXException, ProcessingException {
		try {
			// Grab the context.
			Context context = ContextUtil.obtainContext(objectModel);
            				
              DSpaceObject dso = getDSpaceObject(context);
              if (!(dso.getType() == Constants.COLLECTION || dso.getType() == Constants.ITEM))
              {
                  // The handle is valid but the object is not a collection or item, i.e. it's probably a community
                  throw new ResourceNotFoundException("Unable to perform NLM dissemination for "+dso.getHandle()+". NLM crosswalk is only valid for Collections and Items.");
              }
 
              // Instantiate and execute the NLM plugin
              
              
              DisseminationCrosswalk dimxwalk = (DisseminationCrosswalk)PluginManager.getNamedPlugin(DisseminationCrosswalk.class,"dim");
              DisseminationCrosswalk nlmxwalk = (DisseminationCrosswalk)PluginManager.getNamedPlugin(DisseminationCrosswalk.class,"nlm");
              
              //Set the NLM DocType and root element
              DocType nlmtype = new DocType("ArticleSet", "-//NLM//DTD PubMed 2.0//EN","http://www.ncbi.nlm.nih.gov:80/entrez/query/static/PubMed.dtd");      
              Element nlmroot = new Element(nlmtype.getElementName());
              
              //Create the DIM document
              //Element dimroot = new Element("dims");
              //Document dimdoc = new Document(dimroot);           
              //dimroot = dimdoc.getRootElement();
              
              if (dso.getType() == Constants.COLLECTION)
              {   
            	  Collection collection = (Collection) dso;
            	  
                  if (collection.getItems() == null)
                  {
                      throw new ResourceNotFoundException("Unable to locate items for collection.");
                  }
                  
              	ItemIterator iterator = collection.getItems();
               
                // Crosswalk metadata for each item in the collection
                try
                {
                    while (iterator.hasNext())
                    {
                        Item item = iterator.next(); 
                        //Element dimitem = dimxwalk.disseminateElement(item);
  	                    
                        // Use JDOM to insert crosswalked metadata for the item into the parent element
                        Element nlm = nlmxwalk.disseminateElement(item);
  	                    nlmroot.addContent(nlm);
                        //dimroot.addContent(dimitem);
                    }
                }
                finally
                {
                    if (iterator != null)
                    {
                        iterator.close();
                    }
                }
              }
              else if (dso.getType() == Constants.ITEM)
              {
                  Item item = (Item) dso;
                  
            	  if (item == null)
                  {
                      throw new ResourceNotFoundException("Unable to locate item.");
                  }                
                  Element nlm = nlmxwalk.disseminateElement(item);
                  nlmroot.addContent(nlm);
                  //Element dimitem = dimxwalk.disseminateElement(item);
                  //dimroot.addContent(dimitem);
              }

              // Create the NLM document with root element and DTD for the Article list.
                Document nlmdoc = new Document(nlmroot, nlmtype);   
                
                // Transform DIM item list to NLM document with proper root element and doctype
                //Element nlmlist = nlmxwalk.disseminateElement(dimdoc);
                //nlmdoc.addContent(nlmroot);

              //XSLTransformer nlmtx = nlmxwalk.getTransformer("dissemination");

              //nlmdoc = nlmtx.transform(dimdoc);
              
               // Output the result
                SAXOutputter out = new SAXOutputter(contentHandler);
                out.setLexicalHandler(lexicalHandler);
            
                out.output(nlmdoc);
			
		} catch (JDOMException je) {
			throw new ProcessingException(je);
		} catch (AuthorizeException ae) {
			throw new ProcessingException(ae);
		} catch (CrosswalkException ce) {
			throw new ProcessingException(ce);
		} catch (SQLException sqle) {
			throw new ProcessingException(sqle);
		}
	}
	
	private DSpaceObject getDSpaceObject(Context context) throws SQLException, CrosswalkException 
	{			
        // Determine the correct adatper to use for this item
        String handle = parameters.getParameter("handle",null);
        String internal = parameters.getParameter("internal",null);
        
		 if (handle != null)
         {
			// Specified using a regular handle. 
         	DSpaceObject dso = HandleManager.resolveToObject(context, handle);         	
            return dso;
         }
         else if (internal != null)
         {
        	// Internal identifier, format: "type:id".
         	String[] parts = internal.split(":");
         	
         	if (parts.length == 2)
         	{
         		String type = parts[0];
         		int id = Integer.valueOf(parts[1]);         		
                return DSpaceObject.find(context,Constants.getTypeID(type),id);        		
         	}
         }
		 return null;
	}	
}
